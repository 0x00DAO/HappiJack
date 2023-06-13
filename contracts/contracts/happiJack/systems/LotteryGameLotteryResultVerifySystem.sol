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
    }
}
