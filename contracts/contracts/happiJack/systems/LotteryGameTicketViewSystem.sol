// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "../../eon/utils/VersionUpgradeable.sol";

import {System} from "../../eon/systems/System.sol";

import {AddressUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";

import {LotteryGameStatus, TokenType} from "../tables/LotteryGameEnums.sol";
import "../tables/Tables.sol";
import {GameSystems} from "./GameSystems.sol";

uint256 constant ID = uint256(
    keccak256("happiJack.systems.LotteryGameTicketViewSystem")
);

contract LotteryGameTicketViewSystem is
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

    struct lotteryTicketInfo {
        uint256 lotteryGameId;
        uint256 lotteryGameStatus;
        uint256 lotteryTicketId;
        uint256 luckyNumber;
        address owner;
        uint256 buyTime;
        uint256 bonusPercent;
        bool isRewardBonus;
        uint256 rewardTime;
        uint256 rewardLevel;
        uint256 rewardAmount;
    }

    function getLotteryTicketInfo(
        uint256 lotteryTicketId
    ) public view returns (lotteryTicketInfo memory) {
        require(
            LotteryTicketTable.hasRecord(lotteryTicketId),
            "LotteryTicketTable: Lottery ticket does not exist"
        );

        lotteryTicketInfo memory ticketInfo;
        ticketInfo.lotteryTicketId = lotteryTicketId;
        ticketInfo.lotteryGameId = LotteryTicketTable.getLotteryGameId(
            lotteryTicketId
        );
        ticketInfo.lotteryGameStatus = LotteryGameTable.getStatus(
            ticketInfo.lotteryGameId
        );
        ticketInfo.luckyNumber = LotteryTicketTable.getLuckyNumber(
            lotteryTicketId
        );
        ticketInfo.owner = LotteryTicketTable.getOwner(lotteryTicketId);
        ticketInfo.buyTime = LotteryTicketTable.getBuyTime(lotteryTicketId);
        ticketInfo.bonusPercent = LotteryTicketTable.getBonusPercent(
            lotteryTicketId
        );

        //query reward info
        if (ticketInfo.lotteryGameStatus == uint256(LotteryGameStatus.Ended)) {
            ticketInfo.isRewardBonus = LotteryTicketBonusRewardTable.hasRecord(
                lotteryTicketId
            );
            if (ticketInfo.isRewardBonus) {
                ticketInfo.rewardTime = LotteryTicketBonusRewardTable
                    .getRewardTime(lotteryTicketId);
            }

            (ticketInfo.rewardLevel, ticketInfo.rewardAmount, ) = GameSystems
                .getLotteryGameTicketBonusRewardSystem()
                .getClaimRewardAmount(lotteryTicketId);
        }

        return ticketInfo;
    }
}
