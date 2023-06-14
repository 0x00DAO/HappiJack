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

uint256 constant ID = uint256(
    keccak256("happiJack.systems.LotteryGameBonusPoolSystem")
);

contract LotteryGameBonusPoolSystem is
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

    function createLotteryGamePool(
        uint256 lotteryGameId_,
        TokenType tokenType_,
        address tokenAddress_,
        uint256 initialAmount_
    ) public payable onlyRole(SYSTEM_INTERNAL_ROLE) {
        //check if lottery game exists
        require(
            LotteryGameTable.hasRecord(lotteryGameId_),
            "LotteryGameBonusPoolSystem: Lottery game does not exist"
        );

        //check if lottery game pool exists
        require(
            LotteryGameBonusPoolTable.hasRecord(lotteryGameId_) == false,
            "LotteryGameBonusPoolSystem: Lottery game pool already exists"
        );

        //check if token type is valid
        require(
            tokenType_ == TokenType.ETH || tokenType_ == TokenType.ERC20,
            "LotteryGameBonusPoolSystem: Invalid token type"
        );

        //check if token address is valid
        if (tokenType_ == TokenType.ERC20) {
            require(
                tokenAddress_ != address(0),
                "LotteryGameBonusPoolSystem: Invalid token address"
            );
        }

        //check if initial amount is valid
        require(
            initialAmount_ > 0,
            "LotteryGameBonusPoolSystem: Invalid initial amount"
        );

        //check if token type is ETH
        if (tokenType_ == TokenType.ETH) {
            require(
                msg.value == initialAmount_,
                "LotteryGameBonusPoolSystem: Invalid initial amount"
            );
        } else if (tokenType_ == TokenType.ERC20) {
            require(
                false,
                "LotteryGameBonusPoolSystem: ERC20 not supported yet"
            );
        }

        //create lottery game pool
        LotteryGameBonusPoolTable.setTotalAmount(
            lotteryGameId_,
            initialAmount_
        );
        LotteryGameBonusPoolTable.setBonusAmount(
            lotteryGameId_,
            initialAmount_
        );
        LotteryGameBonusPoolTable.setOwnerFeeAmount(lotteryGameId_, 0);
        LotteryGameBonusPoolTable.setDevelopFeeAmount(lotteryGameId_, 0);
        LotteryGameBonusPoolTable.setVerifyFeeAmount(lotteryGameId_, 0);
        LotteryGameBonusPoolTable.setBonusAmountWithdraw(lotteryGameId_, 0);
    }

    function addBonusPoolTicketETH(
        uint256 lotteryGameId_,
        uint256 ticketId_
    ) public payable onlyRole(SYSTEM_INTERNAL_ROLE) {
        requireLotteryGameIdVaild(lotteryGameId_);

        uint256 depositAmount = msg.value;

        require(
            LotteryGameConfigTicketTable.getTokenType(lotteryGameId_) ==
                uint256(TokenType.ETH),
            "LotteryGameBonusPoolSystem: Invalid token type"
        );
        //check depositAmount is valid
        require(
            depositAmount > 0 &&
                depositAmount >=
                LotteryGameConfigTicketTable.getTicketPrice(lotteryGameId_),
            "LotteryGameBonusPoolSystem: Invalid deposit amount"
        );

        //add Total Amount
        LotteryGameBonusPoolTable.setTotalAmount(
            lotteryGameId_,
            LotteryGameBonusPoolTable.getTotalAmount(lotteryGameId_) +
                depositAmount
        );

        //add Develop Fee Amount
        uint256 developFeeAmount = (depositAmount *
            LotteryGameConfigFeeTable.getDevelopFeeRate(lotteryGameId_)) / 100;
        LotteryGameBonusPoolTable.setDevelopFeeAmount(
            lotteryGameId_,
            LotteryGameBonusPoolTable.getDevelopFeeAmount(lotteryGameId_) +
                developFeeAmount
        );

        //add Verify Fee Amount
        uint256 verifyFeeAmount = (depositAmount *
            LotteryGameConfigFeeTable.getVerifyFeeRate(lotteryGameId_)) / 100;
        LotteryGameBonusPoolTable.setVerifyFeeAmount(
            lotteryGameId_,
            LotteryGameBonusPoolTable.getVerifyFeeAmount(lotteryGameId_) +
                verifyFeeAmount
        );

        //add Owner Fee Amount
        uint256 ownerFeeAmount = (depositAmount *
            LotteryGameConfigFeeTable.getOwnerFeeRate(lotteryGameId_)) / 100;
        LotteryGameBonusPoolTable.setOwnerFeeAmount(
            lotteryGameId_,
            LotteryGameBonusPoolTable.getOwnerFeeAmount(lotteryGameId_) +
                ownerFeeAmount
        );

        //add Bonus Amount
        uint256 bonusAmount = depositAmount -
            developFeeAmount -
            ownerFeeAmount -
            verifyFeeAmount;
        LotteryGameBonusPoolTable.setBonusAmount(
            lotteryGameId_,
            LotteryGameBonusPoolTable.getBonusAmount(lotteryGameId_) +
                bonusAmount
        );
    }

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

        LotteryGameLotteryWalletSafeBoxSystem(
            getSystemAddress(LotteryGameLotteryWalletSafeBoxSystemID)
        ).depositETH{value: amount_}(to_);

        //substract bonus amount
        LotteryGameBonusPoolTable.setBonusAmountWithdraw(
            lotteryGameId_,
            LotteryGameBonusPoolTable.getBonusAmountWithdraw(lotteryGameId_) +
                amount_
        );
    }
}
