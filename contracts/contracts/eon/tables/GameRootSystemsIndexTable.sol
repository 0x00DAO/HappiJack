// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {IStore} from "../interface/IStore.sol";
import {System} from "../systems/System.sol";
import {StoreDelegate} from "../store/StoreDelegate.sol";

bytes32 constant _tableId = bytes32(
    keccak256(abi.encodePacked("tableId", "eon", "GameRootSystemsIndexTable"))
);
bytes32 constant GameRootSystemsIndexTableId = _tableId;

library GameRootSystemsIndexTable {
    function entityKeys(
        address systemAddress
    ) internal pure returns (bytes32[] memory) {
        bytes32[] memory _keyTuple = new bytes32[](1);
        _keyTuple[0] = bytes32(uint256(uint160(systemAddress)));
        return _keyTuple;
    }

    /** Set address */
    function set(address systemAddress, uint256 systemId) internal {
        bytes32[] memory _keyTuple = entityKeys(systemAddress);

        StoreDelegate.Store().setField(
            _tableId,
            _keyTuple,
            0,
            abi.encodePacked(systemId)
        );
    }

    /** Get get address */
    function get(
        address systemAddress
    ) internal view returns (uint256 systemId) {
        bytes32[] memory _keyTuple = entityKeys(systemAddress);

        bytes memory _blob = StoreDelegate.Store().getField(
            _tableId,
            _keyTuple,
            0
        );

        if (_blob.length == 0) return 0;
        return abi.decode(_blob, (uint256));
    }

    /** Delete address */
    function deleteRecord(address systemAddress) internal {
        bytes32[] memory _keyTuple = entityKeys(systemAddress);

        StoreDelegate.Store().deleteRecord(_tableId, _keyTuple, 1);
    }
}
