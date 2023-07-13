// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@zero-dao/eon/contracts/eon/utils/VersionUpgradeable.sol";

import {System} from "@zero-dao/eon/contracts/eon/systems/System.sol";

import {AddressUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";

import {LotteryGameStatus, TokenType} from "../tables/LotteryGameEnums.sol";
import "../tables/Tables.sol";

import {LotteryGameTicketNFTSystem, ID as LotteryGameTicketNFTSystemID} from "./LotteryGameTicketNFTSystem.sol";
import {LotteryGameConstantVariableSystem, ID as LotteryGameConstantVariableSystemID} from "./LotteryGameConstantVariableSystem.sol";

uint256 constant ID = uint256(
    keccak256("happiJack.systems.LotteryGameTicketSystem")
);

contract LotteryGameTicketSystem is
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

    event LotteryTicketCreated(
        uint256 indexed lotteryGameId,
        uint256 indexed lotteryGameTicketId,
        address indexed owner,
        uint256 luckyNumber,
        uint256 buyTime
    );

    uint256 public constant ID_LOTTERY_GAME_TICKET =
        uint256(keccak256("happiJack.id.lotteryGameTicket"));

    function createLotteryGameTicketSystem(
        uint256 lotteryGameId_
    ) public onlyRole(SYSTEM_INTERNAL_ROLE) {
        //check if lottery game exists
        require(
            LotteryGameTable.hasRecord(lotteryGameId_) == true,
            "LotteryGameBonusPoolSystem: Lottery game does not exist"
        );

        //check if lottery game ticket does not exist
        require(
            LotteryGameTicketTable.hasRecord(lotteryGameId_) == false,
            "LotteryGameBonusPoolSystem: Lottery game ticket already exists"
        );

        LotteryGameTicketTable.setTicketSoldCount(lotteryGameId_, 0);
    }

    function createLotteryTicket(
        uint256 lotteryGameId_,
        address owner_,
        uint256 luckyNumber_,
        uint256 buyTime_
    ) public onlyRole(SYSTEM_INTERNAL_ROLE) returns (uint256) {
        //check if lottery game exists
        require(
            LotteryGameTable.hasRecord(lotteryGameId_) == true,
            "LotteryGameBonusPoolSystem: Lottery game does not exist"
        );

        require(
            luckyNumber_ > 0 && luckyNumber_ < 999999,
            "LotteryGameTicketSystem: Invalid lucky number"
        );

        require(owner_ != address(0), "LotteryGameTicketSystem: Invalid owner");

        uint256 lotteryGameTicketId_ = IdCounterTable.get(
            ID_LOTTERY_GAME_TICKET,
            1000
        );
        IdCounterTable.increase(ID_LOTTERY_GAME_TICKET, 1000);

        //create lottery game ticket nft
        LotteryGameTicketNFTSystem(
            getSystemAddress(LotteryGameTicketNFTSystemID)
        ).mintTicket(owner_, lotteryGameTicketId_);

        LotteryTicketTable.setLotteryGameId(
            lotteryGameTicketId_,
            lotteryGameId_
        );
        LotteryTicketTable.setOwner(lotteryGameTicketId_, owner_);
        LotteryTicketTable.setLuckyNumber(lotteryGameTicketId_, luckyNumber_);
        LotteryTicketTable.setBuyTime(lotteryGameTicketId_, buyTime_);
        LotteryTicketTable.setBonusPercent(
            lotteryGameTicketId_,
            LotteryGameConstantVariableSystem(
                getSystemAddress(LotteryGameConstantVariableSystemID)
            ).getTicketBonusPercent()
        );

        //emit event
        emit LotteryTicketCreated(
            lotteryGameTicketId_,
            lotteryGameId_,
            owner_,
            luckyNumber_,
            buyTime_
        );

        return lotteryGameTicketId_;
    }
}
