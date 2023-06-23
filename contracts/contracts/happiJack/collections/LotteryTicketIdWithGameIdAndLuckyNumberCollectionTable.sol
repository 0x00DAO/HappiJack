// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {IStoreU256Set} from "../../eon/interface/IStore.sol";
import {StoreU256SetSystemDelegate} from "../../eon/store/StoreU256SetSystemDelegate.sol";
import {addressToEntity, entityToAddress} from "../../eon/utils/Utils.sol";

bytes32 constant _tableId = bytes32(
    keccak256(
        abi.encodePacked(
            "tableId",
            "HappiJack",
            "LotteryTicketIdWithGameIdAndLuckyNumberCollectionTable"
        )
    )
);
bytes32 constant LotteryTicketIdWithGameIdAndLuckyNumberCollectionTableId = _tableId;

library LotteryTicketIdWithGameIdAndLuckyNumberCollectionTable {
    /** Get the table's metadata */
    function getMetadata()
        internal
        pure
        returns (string memory, string[] memory)
    {
        string[] memory _fieldNames = new string[](1);
        _fieldNames[0] = "LotteryGameId"; // uint256
        return (
            "LotteryTicketIdWithGameIdAndLuckyNumberCollectionTable",
            _fieldNames
        );
    }

    function entityKeys(
        uint256 lotteryGameId,
        uint256 luckyNumber
    ) internal pure returns (bytes32[] memory) {
        bytes32[] memory _keyTuple = new bytes32[](3);
        _keyTuple[0] = _tableId;
        _keyTuple[1] = bytes32(lotteryGameId);
        _keyTuple[2] = bytes32(luckyNumber);

        return _keyTuple;
    }

    function store() internal view returns (IStoreU256Set) {
        return StoreU256SetSystemDelegate.StoreU256Set();
    }

    function add(
        uint256 lotteryGameId,
        uint256 luckyNumber,
        uint256 ticketId
    ) internal returns (bool) {
        bytes32[] memory _keyTuple = entityKeys(lotteryGameId, luckyNumber);
        return store().add(_keyTuple, ticketId);
    }

    function remove(
        uint256 lotteryGameId,
        uint256 luckyNumber,
        uint256 ticketId
    ) internal returns (bool) {
        bytes32[] memory _keyTuple = entityKeys(lotteryGameId, luckyNumber);
        return store().remove(_keyTuple, ticketId);
    }

    function at(
        uint256 lotteryGameId,
        uint256 luckyNumber,
        uint256 index
    ) internal view returns (uint256) {
        bytes32[] memory _keyTuple = entityKeys(lotteryGameId, luckyNumber);
        return store().at(_keyTuple, index);
    }

    function values(
        uint256 lotteryGameId,
        uint256 luckyNumber
    ) internal view returns (uint256[] memory) {
        bytes32[] memory _keyTuple = entityKeys(lotteryGameId, luckyNumber);
        return store().values(_keyTuple);
    }

    function values(
        uint256 lotteryGameId,
        uint256[] memory luckyNumbers
    ) internal view returns (uint256[][] memory) {
        bytes32[][] memory _keyTuples = new bytes32[][](luckyNumbers.length);
        for (uint256 i = 0; i < luckyNumbers.length; i++) {
            _keyTuples[i] = entityKeys(lotteryGameId, luckyNumbers[i]);
        }
        return store().values(_keyTuples);
    }

    function has(
        uint256 lotteryGameId,
        uint256 luckyNumber,
        uint256 ticketId
    ) internal view returns (bool) {
        bytes32[] memory _keyTuple = entityKeys(lotteryGameId, luckyNumber);
        return store().has(_keyTuple, ticketId);
    }

    function length(
        uint256 lotteryGameId,
        uint256 luckyNumber
    ) internal view returns (uint256) {
        bytes32[] memory _keyTuple = entityKeys(lotteryGameId, luckyNumber);
        return store().length(_keyTuple);
    }
}
