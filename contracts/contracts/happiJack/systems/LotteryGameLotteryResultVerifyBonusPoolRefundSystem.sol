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
import {LotteryGameConstantVariableSystem, ID as LotteryGameConstantVariableSystemID} from "./LotteryGameConstantVariableSystem.sol";
import {LotteryGameBonusPoolWithdrawSystem, ID as LotteryGameBonusPoolWithdrawSystemID} from "./LotteryGameBonusPoolWithdrawSystem.sol";

uint256 constant ID = uint256(
    keccak256(
        "happiJack.systems.LotteryGameLotteryResultVerifyBonusPoolRefundSystem"
    )
);

contract LotteryGameLotteryResultVerifyBonusPoolRefundSystem is
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

    event LotteryGameResultVerified(
        uint256 indexed lotteryGameId,
        uint256 indexed luckyNumber
    );

    function bonusPoolRefund(
        uint256 lotteryGameId_
    ) public onlyRole(SYSTEM_INTERNAL_ROLE) {
        //Refund pool percentage
        uint256 bonusPoolRefundPercent = 0;
        //whether there is a 1-level bonus
        if (
            LotteryGameLotteryCoreSystem(
                getSystemAddress(LotteryGameLotteryCoreSystemID)
            ).getLotteryLuckNumbersAtOrder(lotteryGameId_, 0).length == 0
        ) {
            bonusPoolRefundPercent = 70 + 20 + 5 + 5;
        }
        //whether there is a 2-level bonus
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
        //whether there is a 3-level bonus
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
        //whether there is a 4-level bonus
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
            //Refund pool
            LotteryGameBonusPoolWithdrawSystem(
                getSystemAddress(LotteryGameBonusPoolWithdrawSystemID)
            ).withdrawBonusAmountToWalletSafeBoxETH(
                    lotteryGameId_,
                    LotteryGameConfigTable.getOwner(lotteryGameId_),
                    (LotteryGameBonusPoolTable.getBonusAmount(lotteryGameId_) *
                        bonusPoolRefundPercent) / 100
                );
        }
    }
}
