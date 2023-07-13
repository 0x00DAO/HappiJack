// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {IStoreU256Set} from "@zero-dao/eon/contracts/eon/interface/IStore.sol";
import {StoreU256SetSystemDelegate} from "@zero-dao/eon/contracts/eon/store/StoreU256SetSystemDelegate.sol";
import {addressToEntity, entityToAddress} from "@zero-dao/eon/contracts/eon/utils/Utils.sol";

bytes32 constant _tableId = bytes32(
    keccak256(
        abi.encodePacked(
            "tableId",
            "HappiJack",
            "LotteryLuckyNumberWithGameIdAndWinOrderCollectionTableTable"
        )
    )
);
bytes32 constant LotteryLuckyNumberWithGameIdAndWinOrderCollectionTableId = _tableId;

library LotteryLuckyNumberWithGameIdAndWinOrderCollectionTable {
    /** Get the table's metadata */
    function getMetadata()
        internal
        pure
        returns (string memory, string[] memory)
    {
        string[] memory _fieldNames = new string[](1);
        _fieldNames[0] = "luckyNumber"; // uint256
        return (
            "LotteryLuckyNumberWithGameIdAndWinOrderCollectionTable",
            _fieldNames
        );
    }

    function entityKeys(
        uint256 lotteryGameId,
        uint256 winOrder
    ) internal pure returns (bytes32[] memory) {
        bytes32[] memory _keyTuple = new bytes32[](3);
        _keyTuple[0] = _tableId;
        _keyTuple[1] = bytes32(lotteryGameId);
        _keyTuple[2] = bytes32(winOrder);

        return _keyTuple;
    }

    function store() internal view returns (IStoreU256Set) {
        return StoreU256SetSystemDelegate.StoreU256Set();
    }

    function add(
        uint256 lotteryGameId,
        uint256 winOrder,
        uint256[] memory datums
    ) internal returns (bool) {
        bytes32[] memory _keyTuple = entityKeys(lotteryGameId, winOrder);
        return store().add(_keyTuple, datums);
    }

    function add(
        uint256 lotteryGameId,
        uint256 winOrder,
        uint256 value
    ) internal returns (bool) {
        bytes32[] memory _keyTuple = entityKeys(lotteryGameId, winOrder);
        return store().add(_keyTuple, value);
    }

    function remove(
        uint256 lotteryGameId,
        uint256 winOrder,
        uint256 value
    ) internal returns (bool) {
        bytes32[] memory _keyTuple = entityKeys(lotteryGameId, winOrder);
        return store().remove(_keyTuple, value);
    }

    function removeAll(uint256 lotteryGameId, uint256 winOrder) internal {
        bytes32[] memory _keyTuple = entityKeys(lotteryGameId, winOrder);
        return store().removeAll(_keyTuple);
    }

    function at(
        uint256 lotteryGameId,
        uint256 winOrder,
        uint256 index
    ) internal view returns (uint256) {
        bytes32[] memory _keyTuple = entityKeys(lotteryGameId, winOrder);
        return store().at(_keyTuple, index);
    }

    function values(
        uint256 lotteryGameId,
        uint256 winOrder
    ) internal view returns (uint256[] memory) {
        bytes32[] memory _keyTuple = entityKeys(lotteryGameId, winOrder);
        return store().values(_keyTuple);
    }

    function has(
        uint256 lotteryGameId,
        uint256 winOrder,
        uint256 value
    ) internal view returns (bool) {
        bytes32[] memory _keyTuple = entityKeys(lotteryGameId, winOrder);
        return store().has(_keyTuple, value);
    }

    function length(
        uint256 lotteryGameId,
        uint256 winOrder
    ) internal view returns (uint256) {
        bytes32[] memory _keyTuple = entityKeys(lotteryGameId, winOrder);
        return store().length(_keyTuple);
    }
}
