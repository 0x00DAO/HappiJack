// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {IStore} from "../../../eon/interface/IStore.sol";
import {System} from "../../../eon/System.sol";
import {StoreDelegate} from "../../../eon/StoreDelegate.sol";

bytes32 constant _tableId = bytes32(
    keccak256(abi.encodePacked("tableId", "MiniGameBonusTable"))
);
bytes32 constant MiniGameBonusTableId = _tableId;

library MiniGameBonusTable {
    /** Set amount */
    function set(address owner, uint256 amount) internal {
        bytes32[] memory _keyTuple = new bytes32[](2);
        _keyTuple[0] = bytes32(uint256(uint160((owner))));

        StoreDelegate.Store().setField(
            _tableId,
            _keyTuple,
            0,
            abi.encodePacked((amount))
        );
    }

    /** Get amount */
    function get(address owner) internal view returns (uint256 amount) {
        bytes32[] memory _keyTuple = new bytes32[](2);
        _keyTuple[0] = bytes32(uint256(uint160((owner))));

        bytes memory _blob = StoreDelegate.Store().getField(
            _tableId,
            _keyTuple,
            0
        );

        if (_blob.length == 0) return 0;
        return abi.decode(_blob, (uint256));
    }
}
