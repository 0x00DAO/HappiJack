// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import {System} from "../../eon/System.sol";

import {AddressUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";

import {ArraySort} from "../libraries/ArraySort.sol";
import {LotteryGameStatus, TokenType} from "../tables/LotteryGameEnums.sol";

import "../tables/Tables.sol";

uint256 constant ID = uint256(
    keccak256("happiJack.systems.LotteryGameLotteryCoreSystem")
);

contract LotteryGameLotteryCoreSystem is
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

    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;

    // LotteryGameId=>LuckNumber=>LuckNumberCount, LuckNumberCount is the number of times the luck number has been drawn
    // 1=>111111=>10
    // 1=>200000=>2
    mapping(uint256 => mapping(uint256 => uint256)) internal luckNumberCount;

    // LotteryGameId=>Set<LuckNumber>, Set is a list of unique numbers
    // 1=>[111111, 200000]
    mapping(uint256 => EnumerableSetUpgradeable.UintSet) internal luckNumbers;

    function addLotteryGameLuckyNumber(
        uint256 lotteryGameId_,
        uint256 luckNumber_
    ) public onlyRole(SYSTEM_INTERNAL_ROLE) {
        luckNumberCount[lotteryGameId_][luckNumber_] += 1;

        if (!luckNumbers[lotteryGameId_].contains(luckNumber_)) {
            luckNumbers[lotteryGameId_].add(luckNumber_);
        }
    }

    function getLuckNumberCount(
        uint256 lotteryGameId_,
        uint256 luckNumber_
    ) public view returns (uint256) {
        return luckNumberCount[lotteryGameId_][luckNumber_];
    }

    function getLuckNumbers(
        uint256 lotteryGameId_
    ) public view returns (uint256[] memory) {
        return luckNumbers[lotteryGameId_].values();
    }

    function getLuckNumbersWithSort(
        uint256 lotteryGameId_
    ) public view returns (uint256[] memory) {
        uint256[] memory luckNumbers_ = luckNumbers[lotteryGameId_].values();
        return ArraySort.sort(luckNumbers_);
    }
}
