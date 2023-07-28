// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@zero-dao/eon/contracts/eon/utils/VersionUpgradeable.sol";

import {System} from "@zero-dao/eon/contracts/eon/systems/System.sol";

import {AddressUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import {addressToEntity, entityToAddress} from "@zero-dao/eon/contracts/eon/utils/Utils.sol";
import {LotteryGameStatus, TokenType} from "../tables/LotteryGameEnums.sol";

import "../tables/Tables.sol";

import {LotteryGameSystemConfigSetting} from "../libraries/LotteryGameSystemConfigSetting.sol";

import {LotteryGameBonusPoolSystem, ID as LotteryGameBonusPoolSystemID} from "./LotteryGameBonusPoolSystem.sol";
import {LotteryGameTicketSystem, ID as LotteryGameTicketSystemID} from "./LotteryGameTicketSystem.sol";
import {LotteryGameLuckyNumberSystem, ID as LotteryGameLuckyNumberSystemID} from "./LotteryGameLuckyNumberSystem.sol";

uint256 constant ID = uint256(
    keccak256("happiJack.systems.LotteryGameSystemConfig")
);

contract LotteryGameSystemConfig is
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

    function _version() internal pure override returns (uint256) {
        return 2;
    }

    function configGame(
        uint256 lotteryGameId_,
        address owner_,
        string memory ad_,
        uint256 startTime_,
        uint256 during_
    ) public onlyRole(SYSTEM_INTERNAL_ROLE) {
        uint256 endTime_ = startTime_ + during_;
        require(
            startTime_ <= block.timestamp + 5 minutes,
            "start time is in the past"
        );
        require(
            during_ >=
                LotteryGameSystemConfigSetting.CreateGameDurationMinSeconds() &&
                during_ <=
                LotteryGameSystemConfigSetting.CreateGameDurationMaxSeconds(),
            "during is too short"
        );
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
        uint256 developFeeRate_,
        uint256 verifyFeeRate_
    ) public onlyRole(SYSTEM_INTERNAL_ROLE) {
        require(ownerFeeRate_ <= 20, "owner fee rate is too high");
        require(developFeeRate_ <= 20, "develop fee rate is too high");
        require(verifyFeeRate_ <= 5, "verify fee rate is too high");

        //set the lottery game fee info
        LotteryGameConfigFeeTable.setOwnerFeeRate(
            lotteryGameId_,
            ownerFeeRate_
        );
        LotteryGameConfigFeeTable.setDevelopFeeRate(
            lotteryGameId_,
            developFeeRate_
        );
        LotteryGameConfigFeeTable.setVerifyFeeRate(
            lotteryGameId_,
            verifyFeeRate_
        );
    }

    function configGameBonusPool(
        uint256 lotteryGameId_,
        TokenType tokenType_,
        address tokenAddress_,
        uint256 initialAmount_
    ) public onlyRole(SYSTEM_INTERNAL_ROLE) {
        require(tokenType_ == TokenType.ETH, "token type is not supported");
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
        uint256 ticketMaxCount_,
        uint256 ticketMaxCountPerAddress_
    ) public onlyRole(SYSTEM_INTERNAL_ROLE) {
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
        require(
            ticketMaxCountPerAddress_ > 0,
            "ticket max amount per address is zero"
        );

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

        LotteryGameConfigTicketTable.setTicketMaxCountPerAddress(
            lotteryGameId_,
            ticketMaxCountPerAddress_
        );
    }
}
