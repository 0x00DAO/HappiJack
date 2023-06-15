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

import {LotteryGameLotteryCoreSystem, ID as LotteryGameLotteryCoreSystemID} from "./LotteryGameLotteryCoreSystem.sol";
import {LotteryGameBonusPoolSystem, ID as LotteryGameBonusPoolSystemID} from "./LotteryGameBonusPoolSystem.sol";
import {LotteryGameLotteryWalletSafeBoxSystem, ID as LotteryGameLotteryWalletSafeBoxSystemID} from "./LotteryGameLotteryWalletSafeBoxSystem.sol";
import {LotteryGameConstantVariableSystem, ID as LotteryGameConstantVariableSystemID} from "./LotteryGameConstantVariableSystem.sol";

uint256 constant ID = uint256(
    keccak256("happiJack.systems.LotteryGameTicketBonusRewardSystem")
);

contract LotteryGameTicketBonusRewardSystem is
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

    event TicketBonusRewardClaimed(
        uint256 indexed ticketId,
        uint256 indexed lotteryGameId,
        uint256 indexed amount,
        uint256 winnerLevel
    );

    function claimTicketReward(
        uint256 ticketId
    ) external nonReentrant whenNotPaused {
        require(
            LotteryTicketTable.hasRecord(ticketId),
            "LotteryGameTicketBonusRewardSystem: ticket does not exist"
        );

        require(
            LotteryTicketTable.getOwner(ticketId) == _msgSender(),
            "LotteryGameTicketBonusRewardSystem: caller is not the owner of the ticket"
        );

        require(
            LotteryTicketBonusRewardTable.hasRecord(ticketId) == false,
            "LotteryGameTicketBonusRewardSystem: ticket already claimed"
        );

        //check lotter game status
        uint256 lotteryGameId = LotteryTicketTable.getLotteryGameId(ticketId);

        uint256 ticketLuckNumber = LotteryTicketTable.getLuckyNumber(ticketId);

        require(
            LotteryGameTable.getStatus(lotteryGameId) ==
                uint256(LotteryGameStatus.Ended),
            "LotteryGameTicketBonusRewardSystem: lottery game is not completed"
        );

        //查询彩票是否中奖
        uint256 winnerLevel = LotteryGameLotteryCoreSystem(
            getSystemAddress(LotteryGameLotteryCoreSystemID)
        ).getLotteryLuckNumberOrder(lotteryGameId, ticketLuckNumber, 3);

        //0 一等奖 1 二等奖 2 三等奖
        //计算奖金

        require(
            winnerLevel <= 3,
            "LotteryGameTicketBonusRewardSystem: ticket is not a winner"
        );

        //0:1,1:2,2:3,3:4等奖
        _claimReward(lotteryGameId, ticketId, ticketLuckNumber, winnerLevel);
    }

    function _claimReward(
        uint256 lotteryGameId,
        uint256 ticketId,
        uint256 ticketLuckNumber,
        uint256 winnerLevel
    ) internal {
        uint256 bonusAmount = LotteryGameBonusPoolTable.getBonusAmount(
            lotteryGameId
        );
        uint256 bonusAmountRemain = bonusAmount -
            LotteryGameBonusPoolTable.getBonusAmountWithdraw(lotteryGameId);
        require(
            bonusAmountRemain > 0,
            "LotteryGameTicketBonusRewardSystem: bonus pool is empty"
        );
        uint256 bonusRewardPercent = LotteryGameConstantVariableSystem(
            getSystemAddress(LotteryGameConstantVariableSystemID)
        ).getBonusRewardPercent(winnerLevel);
        require(
            bonusRewardPercent > 0,
            "LotteryGameTicketBonusRewardSystem: bonus reward percent is zero"
        );

        uint256 bonusReward = (bonusAmount * bonusRewardPercent) / 100;
        uint256 winnersCount = LotteryGameLotteryCoreSystem(
            getSystemAddress(LotteryGameLotteryCoreSystemID)
        ).getLotteryTicketsAtOrder(lotteryGameId, winnerLevel).length;

        require(
            winnersCount > 0,
            "LotteryGameTicketBonusRewardSystem: winners count is zero"
        );

        bonusReward = bonusReward / winnersCount;
        require(
            bonusReward > 0,
            "LotteryGameTicketBonusRewardSystem: bonus reward is zero"
        );

        //set bonus reward
        LotteryTicketBonusRewardTable.setLotteryGameId(ticketId, lotteryGameId);
        LotteryTicketBonusRewardTable.setIsRewardBonus(ticketId, true);
        LotteryTicketBonusRewardTable.setRewardTime(ticketId, block.timestamp);
        LotteryTicketBonusRewardTable.setRewardLevel(ticketId, winnerLevel);
        LotteryTicketBonusRewardTable.setRewardAmount(ticketId, bonusReward);

        //send bonus from pool
        LotteryGameBonusPoolSystem(
            getSystemAddress(LotteryGameBonusPoolSystemID)
        ).withdrawBonusAmountToWalletSafeBoxETH(
                lotteryGameId,
                _msgSender(),
                bonusReward
            );

        // withdraw bonus to wallet
        LotteryGameLotteryWalletSafeBoxSystem(
            getSystemAddress(LotteryGameLotteryWalletSafeBoxSystemID)
        ).withdrawETH(_msgSender());

        //emit event
        emit TicketBonusRewardClaimed(
            ticketId,
            lotteryGameId,
            bonusReward,
            winnerLevel
        );
    }
}
