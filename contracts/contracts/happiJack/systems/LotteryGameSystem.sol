// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import {System} from "../../eon/System.sol";

import {AddressUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";

import {LotteryGameStatus, TokenType} from "../tables/LotteryGameEnums.sol";

import {IdCounterTable, LotteryGameTable, LotteryGameConfigFeeTable, LotteryGameConfigTable, LotteryGameConfigBonusPoolTable, LotteryGameConfigTicketTable} from "../tables/Tables.sol";

import {LotteryGameBonusPoolSystem, ID as LotteryGameBonusPoolSystemID} from "./LotteryGameBonusPoolSystem.sol";

uint256 constant ID = uint256(keccak256("happiJack.systems.LotteryGameSystem"));

contract LotteryGameSystem is
    Initializable,
    PausableUpgradeable,
    UUPSUpgradeable,
    System,
    ReentrancyGuardUpgradeable
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

        //get the lottery game id
        uint256 lotteryGameId = IdCounterTable.get(ID_LOTTERY_GAME);
        address owner = _msgSender();
        require(
            LotteryGameTable.getOwner(lotteryGameId) == address(0),
            "lottery game id is not empty"
        );
        //increment the id counter
        IdCounterTable.increase(ID_LOTTERY_GAME);

        //create the lottery game
        LotteryGameTable.setOwner(lotteryGameId, owner);
        LotteryGameTable.setStatus(
            lotteryGameId,
            uint256(LotteryGameStatus.Active)
        );

        uint256 initialAmount = 0.005 ether;

        //set the lottery game info
        configGame(lotteryGameId, owner, ad_, startTime_, during_);
        //set the lottery game fee info
        configGameFee(lotteryGameId, 10, 10);
        //set the lottery game bonus pool info
        configGameBonusPool(
            lotteryGameId,
            TokenType.ETH,
            address(0),
            initialAmount
        );
        //create the lottery game pool
        LotteryGameBonusPoolSystem(
            getSystemAddress(LotteryGameBonusPoolSystemID)
        ).createLotteryGamePool{value: msg.value}(
            lotteryGameId,
            TokenType.ETH,
            address(0),
            initialAmount
        );

        //set the lottery game ticket info
        configGameTicket(
            lotteryGameId,
            TokenType.ETH,
            address(0),
            0.0005 ether,
            300
        );

        emit LotteryGameCreated(
            lotteryGameId,
            owner,
            startTime_,
            startTime_ + during_
        );

        return lotteryGameId;
    }

    function configGame(
        uint256 lotteryGameId_,
        address owner_,
        string memory ad_,
        uint256 startTime_,
        uint256 during_
    ) internal {
        uint256 endTime_ = startTime_ + during_;
        require(during_ >= 12 hours, "during is too short");
        require(endTime_ > block.timestamp, "end time is in the past");

        //set the lottery game info
        LotteryGameConfigTable.setOwner(lotteryGameId_, owner_);
        LotteryGameConfigTable.setAd(lotteryGameId_, ad_);
        LotteryGameConfigTable.setStartTime(lotteryGameId_, startTime_);
        LotteryGameConfigTable.setDuring(lotteryGameId_, during_);
    }

    function configGameFee(
        uint256 lotteryGameId_,
        uint256 ownerFeeRate_,
        uint256 developFeeRate_
    ) internal {
        require(ownerFeeRate_ <= 30, "owner fee rate is too high");
        require(developFeeRate_ <= 10, "develop fee rate is too high");

        //set the lottery game fee info
        LotteryGameConfigFeeTable.setOwnerFeeRate(
            lotteryGameId_,
            ownerFeeRate_
        );
        LotteryGameConfigFeeTable.setDevelopFeeRate(
            lotteryGameId_,
            developFeeRate_
        );
    }

    function configGameBonusPool(
        uint256 lotteryGameId_,
        TokenType tokenType_,
        address tokenAddress_,
        uint256 initialAmount_
    ) internal {
        require(
            tokenType_ == TokenType.ETH || tokenType_ == TokenType.ERC20,
            "token type is not supported"
        );
        require(initialAmount_ > 0, "initial amount is zero");
        if (tokenType_ == TokenType.ERC20) {
            require(tokenAddress_ != address(0), "token address is zero");
        } else if (tokenType_ == TokenType.ETH) {
            require(tokenAddress_ == address(0), "token address is not zero");
        }

        //set the lottery game bonus pool info
        LotteryGameConfigBonusPoolTable.setTokenType(
            lotteryGameId_,
            uint256(tokenType_)
        );
        LotteryGameConfigBonusPoolTable.setTokenAddress(
            lotteryGameId_,
            tokenAddress_
        );
        LotteryGameConfigBonusPoolTable.setInitialAmount(
            lotteryGameId_,
            initialAmount_
        );
    }

    function configGameTicket(
        uint256 lotteryGameId_,
        TokenType tokenType_,
        address tokenAddress_,
        uint256 ticketPrice_,
        uint256 ticketMaxCount_
    ) internal {
        require(
            tokenType_ == TokenType.ETH || tokenType_ == TokenType.ERC20,
            "token type is not supported"
        );
        require(ticketPrice_ > 0, "initial amount is zero");
        if (tokenType_ == TokenType.ERC20) {
            require(tokenAddress_ != address(0), "token address is zero");
        } else if (tokenType_ == TokenType.ETH) {
            require(tokenAddress_ == address(0), "token address is not zero");
        }

        require(ticketMaxCount_ > 0, "ticket max amount is zero");
        require(ticketMaxCount_ <= 300, "ticket max amount is too high");

        //set the lottery game ticket info
        LotteryGameConfigTicketTable.setTokenType(
            lotteryGameId_,
            uint256(tokenType_)
        );
        LotteryGameConfigTicketTable.setTokenAddress(
            lotteryGameId_,
            tokenAddress_
        );
        LotteryGameConfigTicketTable.setTicketPrice(
            lotteryGameId_,
            ticketPrice_
        );
        LotteryGameConfigTicketTable.setTicketMaxCount(
            lotteryGameId_,
            ticketMaxCount_
        );
    }

    function getLotteryGame(
        uint256 lotteryGameId_
    ) public view returns (address owner, uint256 status) {
        owner = LotteryGameTable.getOwner(lotteryGameId_);
        status = LotteryGameTable.getStatus(lotteryGameId_);
    }
}
