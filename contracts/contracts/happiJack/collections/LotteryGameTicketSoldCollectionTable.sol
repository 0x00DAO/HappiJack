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
            "LotteryGameTicketSoldCollectionTable"
        )
    )
);
bytes32 constant LotteryGameTicketSoldCollectionTableId = _tableId;

bytes32 constant KeyBuyerByAddress = bytes32(
    keccak256(abi.encodePacked("KeyBuyerByAddress"))
);

library LotteryGameTicketSoldCollectionTable {
    /** Get the table's metadata */
    function getMetadata()
        internal
        pure
        returns (string memory, string[] memory)
    {
        string[] memory _fieldNames = new string[](1);
        _fieldNames[0] = "LotteryGameId"; // uint256
        return ("LotteryGameTicketSoldCollectionTable", _fieldNames);
    }

    function entityKeys(
        uint256 lotteryGameId
    ) internal pure returns (bytes32[] memory) {
        bytes32[] memory _keyTuple = new bytes32[](3);
        _keyTuple[0] = _tableId;
        _keyTuple[1] = KeyBuyerByAddress;
        _keyTuple[2] = bytes32(lotteryGameId);
        // _keyTuple[2] = bytes32(lotteryGameId);

        return _keyTuple;
    }

    function store() internal view returns (IStoreU256Set) {
        return StoreU256SetSystemDelegate.StoreU256Set();
    }

    function add(
        uint256 lotteryGameId,
        address buyerAddress
    ) internal returns (bool) {
        bytes32[] memory _keyTuple = entityKeys(lotteryGameId);
        return store().add(_keyTuple, addressToEntity(buyerAddress));
    }

    function remove(
        uint256 lotteryGameId,
        address buyerAddress
    ) internal returns (bool) {
        bytes32[] memory _keyTuple = entityKeys(lotteryGameId);
        return store().remove(_keyTuple, addressToEntity(buyerAddress));
    }

    function at(
        uint256 lotteryGameId,
        uint256 index
    ) internal view returns (address) {
        bytes32[] memory _keyTuple = entityKeys(lotteryGameId);
        return entityToAddress(store().at(_keyTuple, index));
    }

    function values(
        uint256 lotteryGameId
    ) internal view returns (address[] memory) {
        bytes32[] memory _keyTuple = entityKeys(lotteryGameId);
        return store().valuesAsAddress(_keyTuple);
    }

    function has(
        uint256 lotteryGameId,
        address buyerAddress
    ) internal view returns (bool) {
        bytes32[] memory _keyTuple = entityKeys(lotteryGameId);
        return store().has(_keyTuple, addressToEntity(buyerAddress));
    }
}
