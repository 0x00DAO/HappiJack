// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {IStore} from "../interface/IStore.sol";
import {System} from "../systems/System.sol";
import {StoreDelegate} from "../store/StoreDelegate.sol";

import {addressToEntity, entityToAddress} from "../utils/Utils.sol";

bytes32 constant _tableId = bytes32(
    keccak256(abi.encodePacked("tableId", "eon", "GameRootSystemsTable"))
);
bytes32 constant GameRootSystemsTableId = _tableId;

library GameRootSystemsTable {
    function entityKeys(
        uint256 systemId
    ) internal pure returns (bytes32[] memory) {
        bytes32[] memory _keyTuple = new bytes32[](1);
        _keyTuple[0] = bytes32(systemId);
        return _keyTuple;
    }

    /** Set address */
    function set(uint256 systemId, address systemAddress) internal {
        bytes32[] memory _keyTuple = entityKeys(systemId);

        StoreDelegate.Store().setField(
            _tableId,
            _keyTuple,
            0,
            abi.encodePacked(addressToEntity(systemAddress))
        );
    }

    /** Get get address */
    function get(
        uint256 systemId
    ) internal view returns (address systemAddress) {
        bytes32[] memory _keyTuple = entityKeys(systemId);

        bytes memory _blob = StoreDelegate.Store().getField(
            _tableId,
            _keyTuple,
            0
        );

        if (_blob.length == 0) return address(0);
        return entityToAddress(abi.decode(_blob, (uint256)));
    }

    /** Delete address */
    function deleteRecord(uint256 systemId) internal {
        bytes32[] memory _keyTuple = entityKeys(systemId);

        StoreDelegate.Store().deleteRecord(_tableId, _keyTuple, 1);
    }
}
