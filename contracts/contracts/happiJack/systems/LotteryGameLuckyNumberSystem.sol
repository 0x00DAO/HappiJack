// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import {System} from "../../eon/System.sol";

import {AddressUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";

import {LotteryGameStatus, TokenType} from "../tables/LotteryGameEnums.sol";
import "../tables/Tables.sol";

uint256 constant ID = uint256(
    keccak256("happiJack.systems.LotteryGameLuckyNumberSystem")
);

contract LotteryGameLuckyNumberSystem is
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

    function createLotteryGameLuckyNumber(
        uint256 lotteryGameId_
    ) public onlyRole(SYSTEM_INTERNAL_ROLE) {
        //check if lottery game exists
        require(
            LotteryGameTable.hasRecord(lotteryGameId_),
            "LotteryGameLuckyNumberSystem: Lottery game does not exist"
        );

        require(
            LotteryGameLuckyNumTable.hasRecord(lotteryGameId_) == false,
            "LotteryGameLuckyNumberSystem: Lottery game lucky number already exists"
        );

        //create lottery game lucky number
        LotteryGameLuckyNumTable.setCurrentNumber(lotteryGameId_, 0);
        LotteryGameLuckyNumTable.setSumLotteryTicketLuckyNumber(
            lotteryGameId_,
            0
        );
    }

    function addLotteryGameLuckyNumberByTicket(
        uint256 lotteryGameId_,
        address ticketOwner_,
        uint256 ticketLuckyNumber_
    ) public onlyRole(SYSTEM_INTERNAL_ROLE) {
        //check if lottery game exists
        require(
            LotteryGameTable.hasRecord(lotteryGameId_),
            "LotteryGameLuckyNumberSystem: Lottery game does not exist"
        );

        require(
            LotteryGameLuckyNumTable.hasRecord(lotteryGameId_),
            "LotteryGameLuckyNumberSystem: Lottery game lucky number does not exist"
        );

        //check if lucky number is valid
        require(
            ticketLuckyNumber_ > 0 && ticketLuckyNumber_ <= 999999,
            "LotteryGameLuckyNumberSystem: Lucky number is invalid"
        );

        //next sum lucky number
        uint256 currentSumLotteryTicketLuckyNumber = LotteryGameLuckyNumTable
            .getSumLotteryTicketLuckyNumber(lotteryGameId_) +
            ticketLuckyNumber_;

        LotteryGameLuckyNumTable.setSumLotteryTicketLuckyNumber(
            lotteryGameId_,
            currentSumLotteryTicketLuckyNumber
        );

        LotteryGameLuckyNumTable.setCurrentNumber(
            lotteryGameId_,
            computeLuckyNumber(
                currentSumLotteryTicketLuckyNumber,
                block.difficulty,
                block.timestamp,
                block.number,
                ticketOwner_
            )
        );
    }

    function computeLuckyNumber(
        uint256 totalNumber,
        uint256 blkDiffculty,
        uint256 blkTime,
        uint256 blkNumber,
        address lastLotteryOwner
    ) public pure returns (uint256) {
        uint256 luckyNumber = uint256(
            keccak256(
                abi.encodePacked(
                    totalNumber,
                    blkDiffculty,
                    blkTime,
                    blkNumber,
                    lastLotteryOwner
                )
            )
        );

        //lucky number must be between 1 and 999999
        luckyNumber = (luckyNumber % 999999) + 1;
        return luckyNumber;
    }
}
