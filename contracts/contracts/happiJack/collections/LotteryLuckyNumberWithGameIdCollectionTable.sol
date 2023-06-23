// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {IStoreU256Set} from "../../eon/interface/IStore.sol";
import {StoreU256SetSystemDelegate} from "../../eon/StoreU256SetSystemDelegate.sol";
import {addressToEntity, entityToAddress} from "../../eon/utils.sol";

bytes32 constant _tableId = bytes32(
    keccak256(
        abi.encodePacked(
            "tableId",
            "HappiJack",
            "LotteryLuckyNumberWithGameIdCollectionTable"
        )
    )
);
bytes32 constant LotteryLuckyNumberWithGameIdCollectionTableId = _tableId;

library LotteryLuckyNumberWithGameIdCollectionTable {
    /** Get the table's metadata */
    function getMetadata()
        internal
        pure
        returns (string memory, string[] memory)
    {
        string[] memory _fieldNames = new string[](1);
        _fieldNames[0] = "luckyNumber"; // uint256
        return ("LotteryLuckyNumberWithGameIdCollectionTable", _fieldNames);
    }

    function entityKeys(
        uint256 lotteryGameId
    ) internal pure returns (bytes32[] memory) {
        bytes32[] memory _keyTuple = new bytes32[](2);
        _keyTuple[0] = _tableId;
        _keyTuple[1] = bytes32(lotteryGameId);

        return _keyTuple;
    }

    function store() internal view returns (IStoreU256Set) {
        return StoreU256SetSystemDelegate.StoreU256Set();
    }

    function add(uint256 lotteryGameId, uint256 value) internal returns (bool) {
        bytes32[] memory _keyTuple = entityKeys(lotteryGameId);
        return store().add(_keyTuple, value);
    }

    function remove(
        uint256 lotteryGameId,
        uint256 value
    ) internal returns (bool) {
        bytes32[] memory _keyTuple = entityKeys(lotteryGameId);
        return store().remove(_keyTuple, value);
    }

    function at(
        uint256 lotteryGameId,
        uint256 index
    ) internal view returns (uint256) {
        bytes32[] memory _keyTuple = entityKeys(lotteryGameId);
        return store().at(_keyTuple, index);
    }

    function values(
        uint256 lotteryGameId
    ) internal view returns (uint256[] memory) {
        bytes32[] memory _keyTuple = entityKeys(lotteryGameId);
        return store().values(_keyTuple);
    }

    function has(
        uint256 lotteryGameId,
        uint256 value
    ) internal view returns (bool) {
        bytes32[] memory _keyTuple = entityKeys(lotteryGameId);
        return store().has(_keyTuple, value);
    }

    function length(uint256 lotteryGameId) internal view returns (uint256) {
        bytes32[] memory _keyTuple = entityKeys(lotteryGameId);
        return store().length(_keyTuple);
    }
}
