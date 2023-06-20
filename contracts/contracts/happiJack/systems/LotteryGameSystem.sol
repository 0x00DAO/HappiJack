// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import {System} from "../../eon/System.sol";
import "../../core/contract-upgradeable/VersionUpgradeable.sol";

import {AddressUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";

import {LotteryGameStatus, TokenType} from "../tables/LotteryGameEnums.sol";

import "../tables/Tables.sol";

import {LotteryGameBonusPoolSystem, ID as LotteryGameBonusPoolSystemID} from "./LotteryGameBonusPoolSystem.sol";
import {LotteryGameTicketSystem, ID as LotteryGameTicketSystemID} from "./LotteryGameTicketSystem.sol";
import {LotteryGameLuckyNumberSystem, ID as LotteryGameLuckyNumberSystemID} from "./LotteryGameLuckyNumberSystem.sol";
import {LotteryGameSystemConfig, ID as LotteryGameSystemConfigID} from "./LotteryGameSystemConfig.sol";
import {LotteryGameLotteryNFTSystem, ID as LotteryGameLotteryNFTSystemID} from "./LotteryGameLotteryNFTSystem.sol";

uint256 constant ID = uint256(keccak256("happiJack.systems.LotteryGameSystem"));

contract LotteryGameSystem is
    Initializable,
    PausableUpgradeable,
    UUPSUpgradeable,
    System,
    ReentrancyGuardUpgradeable,
    VersionUpgradeable
{
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address root_) public initializer {
        __Pausable_init();
        __UUPSUpgradeable_init();
        __ReentrancyGuard_init();
        __System_init(ID, root_);

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyRole(UPGRADER_ROLE) {}

    /// custom logic here

    uint256 public constant ID_LOTTERY_GAME =
        uint256(keccak256("happiJack.id.LotteryGame"));

    event LotteryGameCreated(
        uint256 indexed lotteryGameId,
        address indexed owner,
        uint256 startTime,
        uint256 endTime
    );

    function createLotteryGame(
        string memory ad_,
        uint256 startTime_,
        uint256 during_
    ) external payable nonReentrant whenNotPaused returns (uint256) {
        require(
            AddressUpgradeable.isContract(_msgSender()) == false,
            "sender is contract"
        );

        // uint256 endTime_ = startTime_ + during_;
        // require(during_ >= 12 hours, "during is too short");
        // require(endTime_ > block.timestamp, "end time is in the past");

        require(
            LotteryGameActiveGameCollectionTable.length() < 1,
            "too many active games"
        );

        //get the lottery game id
        uint256 lotteryGameId = IdCounterTable.get(ID_LOTTERY_GAME, 10000000);
        address owner = _msgSender();
        require(
            LotteryGameTable.getOwner(lotteryGameId) == address(0),
            "lottery game id is not empty"
        );
        //increment the id counter
        IdCounterTable.increase(ID_LOTTERY_GAME, 10000000);

        //create the lottery game
        LotteryGameTable.setOwner(lotteryGameId, owner);
        LotteryGameTable.setStatus(
            lotteryGameId,
            uint256(LotteryGameStatus.Active)
        );

        uint256 initialPoolAmount = 0.005 ether;
        uint256 initialTicketPrice = 0.0005 ether;

        //set the lottery game info
        LotteryGameSystemConfig(getSystemAddress(LotteryGameSystemConfigID))
            .configGame(lotteryGameId, owner, ad_, startTime_, during_);
        //set the lottery game fee info
        LotteryGameSystemConfig(getSystemAddress(LotteryGameSystemConfigID))
            .configGameFee(lotteryGameId, 10, 10, 1);
        //set the lottery game bonus pool info
        LotteryGameSystemConfig(getSystemAddress(LotteryGameSystemConfigID))
            .configGameBonusPool(
                lotteryGameId,
                TokenType.ETH,
                address(0),
                initialPoolAmount
            );

        //set the lottery game ticket info
        LotteryGameSystemConfig(getSystemAddress(LotteryGameSystemConfigID))
            .configGameTicket(
                lotteryGameId,
                TokenType.ETH,
                address(0),
                initialTicketPrice,
                300,
                1
            );

        //create the lottery game pool
        LotteryGameBonusPoolSystem(
            getSystemAddress(LotteryGameBonusPoolSystemID)
        ).createLotteryGamePool{value: msg.value}(
            lotteryGameId,
            TokenType.ETH,
            address(0),
            initialPoolAmount
        );

        //create the lottery game ticket
        LotteryGameTicketSystem(getSystemAddress(LotteryGameTicketSystemID))
            .createLotteryGameTicketSystem(lotteryGameId);

        //create the lottery lucky number
        LotteryGameLuckyNumberSystem(
            getSystemAddress(LotteryGameLuckyNumberSystemID)
        ).createLotteryGameLuckyNumber(lotteryGameId);

        //create the lottery nft
        LotteryGameLotteryNFTSystem(
            getSystemAddress(LotteryGameLotteryNFTSystemID)
        ).mintNFT(owner, lotteryGameId);

        //increase the lottery game active list
        LotteryGameActiveGameCollectionTable.add(lotteryGameId);

        emit LotteryGameCreated(
            lotteryGameId,
            owner,
            startTime_,
            startTime_ + during_
        );

        return lotteryGameId;
    }

    function getLotteryGame(
        uint256 lotteryGameId_
    ) public view returns (address owner, uint256 status) {
        owner = LotteryGameTable.getOwner(lotteryGameId_);
        status = LotteryGameTable.getStatus(lotteryGameId_);
    }
}
