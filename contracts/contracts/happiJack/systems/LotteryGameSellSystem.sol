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
import "../collections/CollectionTables.sol";

import {LotteryGameBonusPoolSystem, ID as LotteryGameBonusPoolSystemID} from "./LotteryGameBonusPoolSystem.sol";
import {LotteryGameTicketSystem, ID as LotteryGameTicketSystemID} from "./LotteryGameTicketSystem.sol";
import {LotteryGameLuckyNumberSystem, ID as LotteryGameLuckyNumberSystemID} from "./LotteryGameLuckyNumberSystem.sol";
import {LotteryGameLotteryCoreSystem, ID as LotteryGameLotteryCoreSystemID} from "./LotteryGameLotteryCoreSystem.sol";

uint256 constant ID = uint256(
    keccak256("happiJack.systems.LotteryGameSellSystem")
);

contract LotteryGameSellSystem is
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

        //check only one ticket per address
        require(
            addressIsBoughtTicket(lotteryGameId, _msgSender()) == false,
            "LotteryGameSellSystem: you already have a ticket for this lotteryGameId"
        );

        // create ticket
        uint256 ticketId = LotteryGameTicketSystem(
            getSystemAddress(LotteryGameTicketSystemID)
        ).createLotteryTicket(
                lotteryGameId,
                _msgSender(),
                luckyNumber,
                block.timestamp
            );

        _updateTicketSoldCount(lotteryGameId, ticketId);

        LotteryGameTicketSoldCollectionTable.add(lotteryGameId, _msgSender());

        // send ETH to bonus pool
        LotteryGameBonusPoolSystem(
            getSystemAddress(LotteryGameBonusPoolSystemID)
        ).addBonusPoolTicketETH{value: msg.value}(lotteryGameId, ticketId);

        // add lucky number
        LotteryGameLuckyNumberSystem(
            getSystemAddress(LotteryGameLuckyNumberSystemID)
        ).addLotteryGameLuckyNumberByTicket(
                lotteryGameId,
                _msgSender(),
                luckyNumber
            );

        // add lucky number to lottery core
        LotteryGameLotteryCoreSystem(
            getSystemAddress(LotteryGameLotteryCoreSystemID)
        ).addLotteryGameLuckyNumber(lotteryGameId, luckyNumber, ticketId);

        // emit event
        emit LotteryTicketBuy(
            lotteryGameId,
            _msgSender(),
            ticketId,
            luckyNumber
        );

        return ticketId;
    }

    function _updateTicketSoldCount(
        uint256 lotteryGameId_,
        uint256 lotteryGameTicketId_
    ) internal {
        //increase ticket sold count
        LotteryGameTicketTable.setTicketSoldCount(
            lotteryGameId_,
            LotteryGameTicketTable.getTicketSoldCount(lotteryGameId_) + 1
        );

        uint256 lastSoldTicketId_ = LotteryGameTicketTable.getLastSoldTicketId(
            lotteryGameId_
        );

        //set last sold ticket id
        LotteryGameTicketTable.setLastSoldTicketId(
            lotteryGameId_,
            lotteryGameTicketId_
        );

        if (lastSoldTicketId_ > 0) {
            //set last sold ticket bouns percent to 100%
            LotteryTicketTable.setBonusPercent(lastSoldTicketId_, 100);
        }

        //if reached max ticket, set current ticket bouns percent to 100%
        if (
            LotteryGameTicketTable.getTicketSoldCount(lotteryGameId_) ==
            LotteryGameConfigTicketTable.getTicketMaxCount(lotteryGameId_)
        ) {
            LotteryTicketTable.setBonusPercent(lotteryGameTicketId_, 100);
        }
    }

    ///@dev check if address is bought ticket
    function addressIsBoughtTicket(
        uint256 lotteryGameId_,
        address owner_
    ) public view returns (bool) {
        return LotteryGameTicketSoldCollectionTable.has(lotteryGameId_, owner_);
    }
}
