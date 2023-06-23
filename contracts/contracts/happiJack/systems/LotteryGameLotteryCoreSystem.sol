// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "../../core/contract-upgradeable/VersionUpgradeable.sol";

import {System} from "../../eon/System.sol";

import {AddressUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";

import {ArraySort} from "../libraries/ArraySort.sol";
import {LotteryGameStatus, TokenType} from "../tables/LotteryGameEnums.sol";

import "../tables/Tables.sol";
import "../collections/CollectionTables.sol";

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

    // LotteryGameId=>LuckNumber=>[TicketId], LuckNumber is a unique number
    // 1=>111111=>[1, 2, 3]
    // 1=>200000=>[4, 5, 6]
    // LotteryTicketIdWithGameIdAndLuckyNumberCollectionTable

    // LotteryGameId=>Set<LuckNumber>, Set is a list of unique numbers
    // 1=>[111111, 200000]
    // LotteryLuckyNumberWithGameIdCollectionTable

    // LotteryResult
    // LotteryGameId=>Order=>LuckNumbers
    // 1=>1=>[111111, 200000]
    mapping(uint256 => mapping(uint256 => uint256[])) internal lotteryResults;

    //lotteryResultsTicketIds
    // LotteryGameId=>Order=>[TicketId]
    // 1=>1=>[1, 2, 3, 4, 5, 6]
    mapping(uint256 => mapping(uint256 => uint256[]))
        internal lotteryResultsTicketIds;

    function addLotteryGameLuckyNumber(
        uint256 lotteryGameId_,
        uint256 luckNumber_,
        uint256 ticketId_
    ) public onlyRole(SYSTEM_INTERNAL_ROLE) {
        LotteryTicketIdWithGameIdAndLuckyNumberCollectionTable.add(
            lotteryGameId_,
            luckNumber_,
            ticketId_
        );

        LotteryLuckyNumberWithGameIdCollectionTable.add(
            lotteryGameId_,
            luckNumber_
        );
    }

    function getLuckNumberCount(
        uint256 lotteryGameId_,
        uint256 luckNumber_
    ) public view returns (uint256) {
        return
            LotteryTicketIdWithGameIdAndLuckyNumberCollectionTable.length(
                lotteryGameId_,
                luckNumber_
            );
    }

    function getLuckNumbers(
        uint256 lotteryGameId_
    ) public view returns (uint256[] memory) {
        return
            LotteryLuckyNumberWithGameIdCollectionTable.values(lotteryGameId_);
    }

    function getLuckNumbersWithSort(
        uint256 lotteryGameId_
    ) public view returns (uint256[] memory) {
        uint256[] memory luckNumbers_ = getLuckNumbers(lotteryGameId_);

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

    //Get the two-dimensional array sorted by proximity by sorting the array of proximity to the specified number
    //For example, there are numbers 2,4,5. The specified number is 3, then the array sorted by proximity is [[4,2],[5]]
    function getLuckNumberByClosest(
        uint256 lotteryGameId_,
        uint256 luckNumber_,
        uint256 topNumber_
    ) public view returns (uint256[][] memory) {
        require(
            topNumber_ > 0,
            "LotteryGameLotteryCoreSystem: topNumber_ must be greater than 0"
        );

        uint256[] memory luckNumbers_ = getLuckNumbers(lotteryGameId_);
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

        uint256[] memory uniqueLuckNumbers_ = getLuckNumbers(lotteryGameId_);

        for (uint256 i = 0; i < result.length; i++) {
            uint256[] memory temp = result[i];
            //remove exist order
            lotteryResults[lotteryGameId_][i] = new uint256[](0);

            for (uint256 j = 0; j < temp.length; j++) {
                // add luckNumber to order
                lotteryResults[lotteryGameId_][i].push(temp[j]);
            }

            //remove exist luckNumber
            for (uint256 j = 0; j < temp.length; j++) {
                for (uint256 k = 0; k < uniqueLuckNumbers_.length; k++) {
                    if (temp[j] == uniqueLuckNumbers_[k]) {
                        uniqueLuckNumbers_[k] = 0;
                        break;
                    }
                }
            }
        }

        //add the remaining numbers to the last order
        for (uint256 i = 0; i < uniqueLuckNumbers_.length; i++) {
            if (uniqueLuckNumbers_[i] > 0) {
                lotteryResults[lotteryGameId_][topNumber_].push(
                    uniqueLuckNumbers_[i]
                );
            }
        }

        //add ticketId to order
        for (uint256 i = 0; i <= topNumber_; i++) {
            uint256[] memory luckNumbers_ = lotteryResults[lotteryGameId_][i];
            for (uint256 j = 0; j < luckNumbers_.length; j++) {
                uint256[]
                    memory ticketIds_ = LotteryTicketIdWithGameIdAndLuckyNumberCollectionTable
                        .values(lotteryGameId_, luckNumbers_[j]);

                for (uint256 k = 0; k < ticketIds_.length; k++) {
                    uint256 ticketId_ = ticketIds_[k];
                    lotteryResultsTicketIds[lotteryGameId_][i].push(ticketId_);
                }
            }
        }
    }

    function computeLotteryResult(
        uint256 lotteryGameId_,
        uint256 luckNumber_
    ) public onlyRole(SYSTEM_INTERNAL_ROLE) {
        _computeLotteryResult(lotteryGameId_, luckNumber_, 3);
    }

    /// @dev Get the order of the lottery ticket in the lottery results
    function getLotteryLuckNumberOrder(
        uint256 lotteryGameId_,
        uint256 luckNumber_,
        uint256 maxOrder_
    ) public view returns (uint256) {
        require(
            luckNumber_ > 0,
            "LotteryGameLotteryCoreSystem: luckNumber_ must be greater than 0"
        );
        require(
            maxOrder_ > 0,
            "LotteryGameLotteryCoreSystem: maxOrder_ must be greater than 0"
        );
        // uint256 maxOrder_ = 4;
        for (uint256 i = 0; i < maxOrder_; i++) {
            uint256[] memory luckNumbers_ = lotteryResults[lotteryGameId_][i];
            for (uint256 j = 0; j < luckNumbers_.length; j++) {
                if (luckNumbers_[j] == luckNumber_) {
                    return i;
                }
            }
        }

        return maxOrder_;
    }

    function getLotteryLuckNumbersAtOrder(
        uint256 lotteryGameId_,
        uint256 order_
    ) public view returns (uint256[] memory) {
        return lotteryResults[lotteryGameId_][order_];
    }

    ///@dev Get the lottery ticket ID of the specified order and number
    function getLotteryTicketsAtOrder(
        uint256 lotteryGameId_,
        uint256 order_
    ) public view returns (uint256[] memory) {
        return lotteryResultsTicketIds[lotteryGameId_][order_];
    }
}
