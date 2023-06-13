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

    // LotteryGameId=>LuckNumber=>[TicketId], LuckNumberCount is the number of times the luck number has been drawn
    // 1=>111111=>[1, 2, 3]
    // 1=>200000=>[4, 5, 6]
    mapping(uint256 => mapping(uint256 => uint256[]))
        internal luckNumberWithTicketIds;

    // LotteryGameId=>Set<LuckNumber>, Set is a list of unique numbers
    // 1=>[111111, 200000]
    mapping(uint256 => EnumerableSetUpgradeable.UintSet) internal luckNumbers;

    // LotteryResult
    // LotteryGameId=>Order=>LuckNumbers
    // 1=>1=>[111111, 200000]
    mapping(uint256 => mapping(uint256 => uint256[])) internal lotteryResults;

    function addLotteryGameLuckyNumber(
        uint256 lotteryGameId_,
        uint256 luckNumber_,
        uint256 ticketId_
    ) public onlyRole(SYSTEM_INTERNAL_ROLE) {
        luckNumberWithTicketIds[lotteryGameId_][luckNumber_].push(ticketId_);

        if (!luckNumbers[lotteryGameId_].contains(luckNumber_)) {
            luckNumbers[lotteryGameId_].add(luckNumber_);
        }
    }

    function getLuckNumberCount(
        uint256 lotteryGameId_,
        uint256 luckNumber_
    ) public view returns (uint256) {
        return luckNumberWithTicketIds[lotteryGameId_][luckNumber_].length;
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

    function getDistance(
        uint256 luckNumber_,
        uint256 luckNumber2_
    ) internal pure returns (uint256) {
        return
            luckNumber_ > luckNumber2_
                ? luckNumber_ - luckNumber2_
                : luckNumber2_ - luckNumber_;
    }

    //通过对指定数字接近度排序数组,获取按照接近度排序后的二维数组
    //例如 有数字2,4,5.指定数字是3,那么接近度排序后的数组是[[4,2],[5]]
    function getLuckNumberByClosest(
        uint256 lotteryGameId_,
        uint256 luckNumber_,
        uint256 topNumber_
    ) public view returns (uint256[][] memory) {
        require(
            topNumber_ > 0,
            "LotteryGameLotteryCoreSystem: topNumber_ must be greater than 0"
        );

        uint256[] memory luckNumbers_ = luckNumbers[lotteryGameId_].values();
        uint256[][] memory result = new uint256[][](topNumber_);

        //Get the proximity of all numbers to the specified number
        uint256[] memory distanceOrigin = new uint256[](luckNumbers_.length);
        for (uint256 i = 0; i < luckNumbers_.length; i++) {
            distanceOrigin[i] = getDistance(luckNumber_, luckNumbers_[i]);
        }

        //copy
        uint256[] memory distanceCopy = ArraySort.clone(distanceOrigin);

        //Sort by proximity
        uint256[] memory distanceSort = ArraySort.sort(distanceCopy);

        //uniqueness
        uint256[] memory distanceSortUnique = ArraySort.unique(distanceSort);
        //[1,2,3,4,5,6,7,8,9,10]

        //Get the proximity of all numbers to the specified number
        //top topNumber_
        for (
            uint256 i = 0;
            i < distanceSortUnique.length && i < topNumber_;
            i++
        ) {
            uint256[] memory temp = new uint256[](5);
            uint256 tempIndex = 0;
            for (uint256 j = 0; j < distanceOrigin.length; j++) {
                if (distanceOrigin[j] == distanceSortUnique[i]) {
                    temp[tempIndex] = luckNumbers_[j];
                    tempIndex++;
                }
            }

            // remove empty
            uint256[] memory temp2 = new uint256[](tempIndex);
            for (uint256 j = 0; j < tempIndex; j++) {
                temp2[j] = temp[j];
            }
            result[i] = temp2;
        }

        return result;
    }

    function computeLotteryResult(
        uint256 lotteryGameId_,
        uint256 luckNumber_
    ) public onlyRole(SYSTEM_INTERNAL_ROLE) {
        _computeLotteryResult(lotteryGameId_, luckNumber_, 3);
    }

    function _computeLotteryResult(
        uint256 lotteryGameId_,
        uint256 luckNumber_,
        uint256 topNumber_
    ) internal {
        require(
            luckNumber_ > 0,
            "LotteryGameLotteryCoreSystem: luckNumber_ must be greater than 0"
        );

        uint256[][] memory result = getLuckNumberByClosest(
            lotteryGameId_,
            luckNumber_,
            topNumber_
        );

        for (uint256 i = 0; i < result.length; i++) {
            uint256[] memory temp = result[i];
            //remove exist order
            lotteryResults[lotteryGameId_][i] = new uint256[](0);

            for (uint256 j = 0; j < temp.length; j++) {
                lotteryResults[lotteryGameId_][i].push(temp[j]);
            }
        }
    }

    /// @dev Get the order of the lottery ticket in the lottery results
    function getLotteryTicketOrder(
        uint256 lotteryGameId_,
        uint256 ticketId_,
        uint256 maxOrder_
    ) public view returns (uint256) {
        require(
            ticketId_ > 0,
            "LotteryGameLotteryCoreSystem: ticketId_ must be greater than 0"
        );
        require(
            maxOrder_ > 0,
            "LotteryGameLotteryCoreSystem: maxOrder_ must be greater than 0"
        );
        // uint256 maxOrder_ = 4;
        for (uint256 i = 0; i < maxOrder_; i++) {
            uint256[] memory luckNumbers_ = lotteryResults[lotteryGameId_][i];
            for (uint256 j = 0; j < luckNumbers_.length; j++) {
                if (luckNumbers_[j] == ticketId_) {
                    return i;
                }
            }
        }

        return maxOrder_;
    }
}
