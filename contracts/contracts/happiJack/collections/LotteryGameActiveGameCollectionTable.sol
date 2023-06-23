// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {IStoreU256Set} from "../../eon/interface/IStore.sol";
import {StoreU256SetSystemDelegate} from "../../eon/store/StoreU256SetSystemDelegate.sol";

bytes32 constant _tableId = bytes32(
    keccak256(
        abi.encodePacked(
            "tableId",
            "HappiJack",
            "LotteryGameActiveGameCollectionTable"
        )
    )
);
bytes32 constant LotteryGameActiveGameCollectionTableId = _tableId;

bytes32 constant KeyActiveGameCollection = bytes32(
    keccak256(abi.encodePacked("KeyActiveGameCollection"))
);

library LotteryGameActiveGameCollectionTable {
    /** Get the table's metadata */
    function getMetadata()
        internal
        pure
        returns (string memory, string[] memory)
    {
        string[] memory _fieldNames = new string[](1);
        _fieldNames[0] = "LotteryGameId"; // uint256
        return ("LotteryGameActiveGameCollectionTable", _fieldNames);
    }

    function entityKeys() internal pure returns (bytes32[] memory) {
        bytes32[] memory _keyTuple = new bytes32[](2);
        _keyTuple[0] = _tableId;
        _keyTuple[1] = KeyActiveGameCollection;
        // _keyTuple[2] = bytes32(lotteryGameId);

        return _keyTuple;
    }

    function store() internal view returns (IStoreU256Set) {
        return StoreU256SetSystemDelegate.StoreU256Set();
    }

    function add(uint256 lotteryGameId) internal returns (bool) {
        bytes32[] memory _keyTuple = entityKeys();
        return store().add(_keyTuple, lotteryGameId);
    }

    function remove(uint256 lotteryGameId) internal returns (bool) {
        bytes32[] memory _keyTuple = entityKeys();
        return store().remove(_keyTuple, lotteryGameId);
    }

    function at(uint256 index) internal view returns (uint256) {
        bytes32[] memory _keyTuple = entityKeys();
        return store().at(_keyTuple, index);
    }

    function values() internal view returns (uint256[] memory) {
        bytes32[] memory _keyTuple = entityKeys();
        return store().values(_keyTuple);
    }

    function has(uint256 lotteryGameId) internal view returns (bool) {
        bytes32[] memory _keyTuple = entityKeys();
        return store().has(_keyTuple, lotteryGameId);
    }

    function length() internal view returns (uint256) {
        bytes32[] memory _keyTuple = entityKeys();
        return store().length(_keyTuple);
    }
}
