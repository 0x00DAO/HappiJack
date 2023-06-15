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
import {LotteryGameConstantVariableSystem, ID as LotteryGameConstantVariableSystemID} from "./LotteryGameConstantVariableSystem.sol";

uint256 constant ID = uint256(
    keccak256("happiJack.systems.LotteryGameLotteryResultVerifySystem")
);

contract LotteryGameLotteryResultVerifySystem is
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

    event LotteryGameResultVerified(
        uint256 indexed lotteryGameId,
        uint256 indexed luckyNumber
    );

    function verify(uint256 lotteryGameId_) public payable {
        //check if lottery game exists
        require(
            LotteryGameTable.hasRecord(lotteryGameId_),
            "LotteryGameLotteryResultVerifySystem: Lottery game does not exist"
        );

        //check if lottery game is in the correct status
        require(
            LotteryGameTable.getStatus(lotteryGameId_) ==
                uint256(LotteryGameStatus.Active),
            "LotteryGameLotteryResultVerifySystem: Lottery game is not in the correct status"
        );

        //check if lottery game has ended
        require(
            LotteryGameConfigTable.getStartTime(lotteryGameId_) +
                LotteryGameConfigTable.getDuring(lotteryGameId_) <=
                block.timestamp,
            "LotteryGameLotteryResultVerifySystem: Lottery game has not ended"
        );

        //set lottery game status to verified
        LotteryGameTable.setStatus(
            lotteryGameId_,
            uint256(LotteryGameStatus.Ended)
        );

        uint256 currentLuckyNumber = LotteryGameLuckyNumTable.getCurrentNumber(
            lotteryGameId_
        );

        uint256 ticketCount = LotteryGameTicketTable.getTicketSoldCount(
            lotteryGameId_
        );

        if (ticketCount > 0) {
            //computeLotteryResult
            LotteryGameLotteryCoreSystem(
                getSystemAddress(LotteryGameLotteryCoreSystemID)
            ).computeLotteryResult(lotteryGameId_, currentLuckyNumber);
        }

        if (ticketCount == 0) {
            //如果没有人买票，退还所有奖池给抽奖发起人
            LotteryGameBonusPoolSystem(
                getSystemAddress(LotteryGameBonusPoolSystemID)
            ).withdrawBonusAmountToWalletSafeBoxETH(
                    lotteryGameId_,
                    LotteryGameConfigTable.getOwner(lotteryGameId_),
                    LotteryGameBonusPoolTable.getBonusAmount(lotteryGameId_) -
                        LotteryGameBonusPoolTable.getBonusAmountWithdraw(
                            lotteryGameId_
                        )
                );
        } else {
            //如果有人买票
            //发放发起者收益
            LotteryGameBonusPoolSystem(
                getSystemAddress(LotteryGameBonusPoolSystemID)
            ).withdrawOwnerFeeAmountToWalletSafeBoxETH(
                    lotteryGameId_,
                    LotteryGameConfigTable.getOwner(lotteryGameId_),
                    LotteryGameBonusPoolTable.getOwnerFeeAmount(lotteryGameId_)
                );

            address developAddress = LotteryGameConstantVariableSystem(
                getSystemAddress(LotteryGameConstantVariableSystemID)
            ).getDeveloperAddress();
            if (developAddress != address(0)) {
                //发放开发者收益
                LotteryGameBonusPoolSystem(
                    getSystemAddress(LotteryGameBonusPoolSystemID)
                ).withdrawDevelopFeeAmountToWalletSafeBoxETH(
                        lotteryGameId_,
                        developAddress,
                        LotteryGameBonusPoolTable.getDevelopFeeAmount(
                            lotteryGameId_
                        )
                    );
            }

            // 发放验证者收益
            LotteryGameBonusPoolSystem(
                getSystemAddress(LotteryGameBonusPoolSystemID)
            ).withdrawVerifyFeeAmountToWalletSafeBoxETH(
                    lotteryGameId_,
                    _msgSender(),
                    LotteryGameBonusPoolTable.getVerifyFeeAmount(lotteryGameId_)
                );

            //如果中奖者不能覆盖1,2,3等的奖金，那么就把奖金退还给发起人
            bonusPoolRefund(lotteryGameId_);
        }

        //emit event
        emit LotteryGameResultVerified(lotteryGameId_, currentLuckyNumber);
    }

    function bonusPoolRefund(uint256 lotteryGameId_) internal {
        //退还奖池百分比
        uint256 bonusPoolRefundPercent = 0;
        //是否有1等级奖金
        if (
            LotteryGameLotteryCoreSystem(
                getSystemAddress(LotteryGameLotteryCoreSystemID)
            ).getLotteryLuckNumbersAtOrder(lotteryGameId_, 0).length == 0
        ) {
            bonusPoolRefundPercent = 70 + 20 + 5 + 5;
        }
        //是否有2等级奖金
        if (
            bonusPoolRefundPercent == 0 &&
            LotteryGameLotteryCoreSystem(
                getSystemAddress(LotteryGameLotteryCoreSystemID)
            ).getLotteryLuckNumbersAtOrder(lotteryGameId_, 1).length ==
            0
        ) {
            bonusPoolRefundPercent =
                LotteryGameConstantVariableSystem(
                    getSystemAddress(LotteryGameConstantVariableSystemID)
                ).getBonusRewardPercent(1) +
                LotteryGameConstantVariableSystem(
                    getSystemAddress(LotteryGameConstantVariableSystemID)
                ).getBonusRewardPercent(2) +
                LotteryGameConstantVariableSystem(
                    getSystemAddress(LotteryGameConstantVariableSystemID)
                ).getBonusRewardPercent(3);
        }
        //是否有3等级奖金
        if (
            bonusPoolRefundPercent == 0 &&
            LotteryGameLotteryCoreSystem(
                getSystemAddress(LotteryGameLotteryCoreSystemID)
            ).getLotteryLuckNumbersAtOrder(lotteryGameId_, 2).length ==
            0
        ) {
            bonusPoolRefundPercent =
                LotteryGameConstantVariableSystem(
                    getSystemAddress(LotteryGameConstantVariableSystemID)
                ).getBonusRewardPercent(2) +
                LotteryGameConstantVariableSystem(
                    getSystemAddress(LotteryGameConstantVariableSystemID)
                ).getBonusRewardPercent(3);
        }
        //是否有4等级奖金
        if (
            bonusPoolRefundPercent == 0 &&
            LotteryGameLotteryCoreSystem(
                getSystemAddress(LotteryGameLotteryCoreSystemID)
            ).getLotteryLuckNumbersAtOrder(lotteryGameId_, 3).length ==
            0
        ) {
            bonusPoolRefundPercent = LotteryGameConstantVariableSystem(
                getSystemAddress(LotteryGameConstantVariableSystemID)
            ).getBonusRewardPercent(3);
        }

        if (bonusPoolRefundPercent != 0) {
            //退还奖池
            LotteryGameBonusPoolSystem(
                getSystemAddress(LotteryGameBonusPoolSystemID)
            ).withdrawBonusAmountToWalletSafeBoxETH(
                    lotteryGameId_,
                    LotteryGameConfigTable.getOwner(lotteryGameId_),
                    (LotteryGameBonusPoolTable.getBonusAmount(lotteryGameId_) *
                        bonusPoolRefundPercent) / 100
                );
        }
    }
}
