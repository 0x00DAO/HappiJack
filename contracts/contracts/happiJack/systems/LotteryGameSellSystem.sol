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

import {LotteryGameBonusPoolSystem, ID as LotteryGameBonusPoolSystemID} from "./LotteryGameBonusPoolSystem.sol";
import {LotteryGameTicketSystem, ID as LotteryGameTicketSystemID} from "./LotteryGameTicketSystem.sol";
import {LotteryGameLuckyNumberSystem, ID as LotteryGameLuckyNumberSystemID} from "./LotteryGameLuckyNumberSystem.sol";

uint256 constant ID = uint256(
    keccak256("happiJack.systems.LotteryGameSellSystem")
);

contract LotteryGameSellSystem is
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

    event LotteryTicketBuy(
        uint256 indexed lotteryGameId,
        address indexed owner,
        uint256 indexed lotteryTicketId,
        uint256 luckyNumber
    );

    function buyLotteryTicketETH(
        uint256 lotteryGameId,
        uint256 luckyNumber
    ) external payable nonReentrant whenNotPaused returns (uint256) {
        // check if lotteryGameId is valid
        require(
            LotteryGameTable.hasRecord(lotteryGameId),
            "LotteryGameSellSystem: lotteryGameId does not exist"
        );

        // check if lotteryGameId is active
        require(
            LotteryGameTable.getStatus(lotteryGameId) ==
                uint256(LotteryGameStatus.Active),
            "LotteryGameSellSystem: lotteryGameId is not active"
        );

        // check lotteryGame time is valid
        require(
            LotteryGameConfigTable.getStartTime(lotteryGameId) <=
                block.timestamp &&
                block.timestamp <=
                LotteryGameConfigTable.getStartTime(lotteryGameId) +
                    LotteryGameConfigTable.getDuring(lotteryGameId),
            "LotteryGameSellSystem: lotteryGameId is not open for sale"
        );

        // check if luckyNumber is valid
        require(
            luckyNumber > 0 && luckyNumber <= 999999,
            "LotteryGameSellSystem: luckyNumber is not valid"
        );

        // check if reached max ticket
        require(
            LotteryGameTicketTable.getTicketSoldCount(lotteryGameId) <
                LotteryGameConfigTicketTable.getTicketMaxCount(lotteryGameId),
            "LotteryGameSellSystem: reached max ticket"
        );

        // check if price type is ETH
        require(
            LotteryGameConfigTicketTable.getTokenType(lotteryGameId) ==
                uint256(TokenType.ETH),
            "LotteryGameSellSystem: price type is not ETH"
        );
        require(
            msg.value > 0 &&
                msg.value ==
                LotteryGameConfigTicketTable.getTicketPrice(lotteryGameId),
            "LotteryGameSellSystem: price is not valid"
        );

        // check only one ticket per address
        // require(
        //     LotteryGameTicketTable.getTicketCountByOwner(
        //         lotteryGameId,
        //         msg.sender
        //     ) == 0,
        //     "LotteryGameSellSystem: only one ticket per address"
        // );

        // create ticket
        uint256 ticketId = LotteryGameTicketSystem(
            getSystemAddress(LotteryGameTicketSystemID)
        ).createLotteryTicket(
                lotteryGameId,
                _msgSender(),
                luckyNumber,
                block.timestamp
            );

        // send ETH to bonus pool
        LotteryGameBonusPoolSystem(
            getSystemAddress(LotteryGameBonusPoolSystemID)
        ).addBonusPoolTicketETH{value: msg.value}(lotteryGameId, ticketId);

        // emit event
        emit LotteryTicketBuy(
            lotteryGameId,
            _msgSender(),
            ticketId,
            luckyNumber
        );
    }
}
