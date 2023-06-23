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

import {LotteryGameLotteryCoreSystem, ID as LotteryGameLotteryCoreSystemID} from "./LotteryGameLotteryCoreSystem.sol";
import {LotteryGameBonusPoolSystem, ID as LotteryGameBonusPoolSystemID} from "./LotteryGameBonusPoolSystem.sol";
import {LotteryGameBonusPoolWithdrawSystem, ID as LotteryGameBonusPoolWithdrawSystemID} from "./LotteryGameBonusPoolWithdrawSystem.sol";
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

    event TicketBonusRewardClaimed(
        uint256 indexed ticketId,
        uint256 indexed lotteryGameId,
        uint256 indexed ticketLuckNumber,
        uint256 amount,
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
        require(
            LotteryGameTable.getStatus(lotteryGameId) ==
                uint256(LotteryGameStatus.Ended),
            "LotteryGameTicketBonusRewardSystem: lottery game is not completed"
        );

        uint256 ticketLuckNumber = LotteryTicketTable.getLuckyNumber(ticketId);

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

    function getClaimRewardAmount(
        uint256 ticketId
    ) public view returns (uint256) {
        uint256 bonusReward = _getClaimRewardAmount(ticketId);
        //get ticket bonus percent
        uint256 bonusRewardPercent = LotteryTicketTable.getBonusPercent(
            ticketId
        );
        return (bonusReward * bonusRewardPercent) / 100;
    }

    function _getClaimRewardAmount(
        uint256 ticketId
    ) internal view returns (uint256) {
        require(
            LotteryTicketBonusRewardTable.hasRecord(ticketId) == false,
            "LotteryGameTicketBonusRewardSystem: ticket already claimed"
        );
        //check lotter game status
        uint256 lotteryGameId = LotteryTicketTable.getLotteryGameId(ticketId);
        require(
            LotteryGameTable.getStatus(lotteryGameId) ==
                uint256(LotteryGameStatus.Ended),
            "LotteryGameTicketBonusRewardSystem: lottery game is not completed"
        );
        uint256 ticketLuckNumber = LotteryTicketTable.getLuckyNumber(ticketId);

        uint256 winnerLevel = LotteryGameLotteryCoreSystem(
            getSystemAddress(LotteryGameLotteryCoreSystemID)
        ).getLotteryLuckNumberOrder(lotteryGameId, ticketLuckNumber, 3);
        require(
            winnerLevel <= 3,
            "LotteryGameTicketBonusRewardSystem: ticket is not a winner"
        );
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
        return bonusReward;
    }

    function _claimReward(
        uint256 lotteryGameId,
        uint256 ticketId,
        uint256 ticketLuckNumber,
        uint256 winnerLevel
    ) internal {
        uint256 bonusReward = _getClaimRewardAmount(ticketId);
        require(
            bonusReward > 0,
            "LotteryGameTicketBonusRewardSystem: bonus reward is zero"
        );

        //get ticket bonus percent
        uint256 bonusRewardPercent = LotteryTicketTable.getBonusPercent(
            ticketId
        );

        address developAddress = LotteryGameConstantVariableSystem(
            getSystemAddress(LotteryGameConstantVariableSystemID)
        ).getDeveloperAddress();
        uint256 ticketOwnerBonusReward = (bonusReward * bonusRewardPercent) /
            100;
        //if not set developer address, all bonus reward to ticket owner
        if (developAddress == address(0)) {
            ticketOwnerBonusReward = bonusReward;
        }

        if (ticketOwnerBonusReward > 0) {
            //set bonus reward
            LotteryTicketBonusRewardTable.setLotteryGameId(
                ticketId,
                lotteryGameId
            );
            LotteryTicketBonusRewardTable.setIsRewardBonus(ticketId, true);
            LotteryTicketBonusRewardTable.setRewardTime(
                ticketId,
                block.timestamp
            );
            LotteryTicketBonusRewardTable.setRewardLevel(ticketId, winnerLevel);
            LotteryTicketBonusRewardTable.setRewardAmount(
                ticketId,
                ticketOwnerBonusReward
            );

            //send bonus from pool
            LotteryGameBonusPoolWithdrawSystem(
                getSystemAddress(LotteryGameBonusPoolWithdrawSystemID)
            ).withdrawBonusAmountToWalletSafeBoxETH(
                    lotteryGameId,
                    _msgSender(),
                    ticketOwnerBonusReward
                );

            // withdraw bonus to wallet
            LotteryGameLotteryWalletSafeBoxSystem(
                getSystemAddress(LotteryGameLotteryWalletSafeBoxSystemID)
            ).withdrawETH(_msgSender());
        }

        if (
            developAddress != address(0) &&
            bonusReward - ticketOwnerBonusReward > 0
        ) {
            //send bonus from pool to developer
            LotteryGameBonusPoolWithdrawSystem(
                getSystemAddress(LotteryGameBonusPoolWithdrawSystemID)
            ).withdrawBonusAmountToWalletSafeBoxETH(
                    lotteryGameId,
                    developAddress,
                    bonusReward - ticketOwnerBonusReward
                );
        }

        //emit event
        emit TicketBonusRewardClaimed(
            ticketId,
            lotteryGameId,
            ticketLuckNumber,
            ticketOwnerBonusReward,
            winnerLevel
        );
    }
}
