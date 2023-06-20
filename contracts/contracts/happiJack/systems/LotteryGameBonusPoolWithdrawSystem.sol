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

import {LotteryGameLotteryWalletSafeBoxSystem, ID as LotteryGameLotteryWalletSafeBoxSystemID} from "./LotteryGameLotteryWalletSafeBoxSystem.sol";
import {LotteryGameBonusPoolSystem, ID as LotteryGameBonusPoolSystemID} from "./LotteryGameBonusPoolSystem.sol";

uint256 constant ID = uint256(
    keccak256("happiJack.systems.LotteryGameBonusPoolWithdrawSystem")
);

contract LotteryGameBonusPoolWithdrawSystem is
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

        // _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        // _grantRole(PAUSER_ROLE, msg.sender);
        // _grantRole(UPGRADER_ROLE, msg.sender);
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

    function requireLotteryGameIdVaild(uint256 lotteryGameId_) internal view {
        //check if lottery game exists
        require(
            LotteryGameTable.hasRecord(lotteryGameId_),
            "LotteryGameBonusPoolSystem: Lottery game does not exist"
        );

        //check if lottery game pool exists
        require(
            LotteryGameBonusPoolTable.hasRecord(lotteryGameId_),
            "LotteryGameBonusPoolSystem: Lottery game pool does not exist"
        );
    }

    function requireWithdrawAmountEthParameterValid(
        uint256 lotteryGameId_,
        address to_
    ) internal view {
        requireLotteryGameIdVaild(lotteryGameId_);
        //check if amount is valid

        //check if to_ is valid
        require(
            to_ != address(0),
            "LotteryGameBonusPoolSystem: Invalid to address"
        );

        //check if token type is ETH
        require(
            LotteryGameConfigTicketTable.getTokenType(lotteryGameId_) ==
                uint256(TokenType.ETH),
            "LotteryGameBonusPoolSystem: Invalid token type"
        );
    }

    function withdrawBonusAmountToWalletSafeBoxETH(
        uint256 lotteryGameId_,
        address to_,
        uint256 amount_
    ) public onlyRole(SYSTEM_INTERNAL_ROLE) {
        requireWithdrawAmountEthParameterValid(lotteryGameId_, to_);

        //check if amount is valid
        require(
            amount_ > 0 &&
                amount_ +
                    LotteryGameBonusPoolTable.getBonusAmountWithdraw(
                        lotteryGameId_
                    ) <=
                LotteryGameBonusPoolTable.getBonusAmount(lotteryGameId_),
            "LotteryGameBonusPoolSystem: Invalid amount"
        );

        LotteryGameBonusPoolSystem(
            getSystemAddress(LotteryGameBonusPoolSystemID)
        ).transferETHToSafeBox(to_, amount_);

        //substract bonus amount
        LotteryGameBonusPoolTable.setBonusAmountWithdraw(
            lotteryGameId_,
            LotteryGameBonusPoolTable.getBonusAmountWithdraw(lotteryGameId_) +
                amount_
        );
    }

    function withdrawOwnerFeeAmountToWalletSafeBoxETH(
        uint256 lotteryGameId_,
        address to_,
        uint256 amount_
    ) public onlyRole(SYSTEM_INTERNAL_ROLE) {
        requireWithdrawAmountEthParameterValid(lotteryGameId_, to_);

        //check if amount is valid
        require(
            amount_ > 0 &&
                amount_ <=
                LotteryGameBonusPoolTable.getOwnerFeeAmount(lotteryGameId_),
            "LotteryGameBonusPoolSystem: Invalid amount"
        );

        LotteryGameBonusPoolSystem(
            getSystemAddress(LotteryGameBonusPoolSystemID)
        ).transferETHToSafeBox(to_, amount_);

        //substract owner fee amount
        LotteryGameBonusPoolTable.setOwnerFeeAmount(
            lotteryGameId_,
            LotteryGameBonusPoolTable.getOwnerFeeAmount(lotteryGameId_) -
                amount_
        );
    }

    function withdrawDevelopFeeAmountToWalletSafeBoxETH(
        uint256 lotteryGameId_,
        address to_,
        uint256 amount_
    ) public onlyRole(SYSTEM_INTERNAL_ROLE) {
        requireWithdrawAmountEthParameterValid(lotteryGameId_, to_);

        //check if amount is valid
        require(
            amount_ > 0 &&
                amount_ <=
                LotteryGameBonusPoolTable.getDevelopFeeAmount(lotteryGameId_),
            "LotteryGameBonusPoolSystem: Invalid amount"
        );

        LotteryGameBonusPoolSystem(
            getSystemAddress(LotteryGameBonusPoolSystemID)
        ).transferETHToSafeBox(to_, amount_);

        //substract develop fee amount
        LotteryGameBonusPoolTable.setDevelopFeeAmount(
            lotteryGameId_,
            LotteryGameBonusPoolTable.getDevelopFeeAmount(lotteryGameId_) -
                amount_
        );
    }

    function withdrawVerifyFeeAmountToWalletSafeBoxETH(
        uint256 lotteryGameId_,
        address to_,
        uint256 amount_
    ) public onlyRole(SYSTEM_INTERNAL_ROLE) {
        requireWithdrawAmountEthParameterValid(lotteryGameId_, to_);

        //check if amount is valid
        require(
            amount_ > 0 &&
                amount_ <=
                LotteryGameBonusPoolTable.getVerifyFeeAmount(lotteryGameId_),
            "LotteryGameBonusPoolSystem: Invalid amount"
        );

        LotteryGameBonusPoolSystem(
            getSystemAddress(LotteryGameBonusPoolSystemID)
        ).transferETHToSafeBox(to_, amount_);

        //substract verify fee amount
        LotteryGameBonusPoolTable.setVerifyFeeAmount(
            lotteryGameId_,
            LotteryGameBonusPoolTable.getVerifyFeeAmount(lotteryGameId_) -
                amount_
        );
    }
}
