// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {IStoreWrite} from "../../../eon/interface/IStore.sol";
import {System} from "../../../eon/System.sol";

bytes32 constant _tableId = bytes32(
    keccak256(abi.encodePacked("tableId", "MiniGameBonusTable"))
);
bytes32 constant MiniGameBonusTableId = _tableId;

library MiniGameBonusTable {
    /** Set amount */
    function set(address owner, uint256 amount) internal {
        bytes32[] memory _keyTuple = new bytes32[](2);
        _keyTuple[0] = bytes32(uint256(uint160((owner))));

        IStoreWrite(address(System(address(this)).getRoot())).setField(
            _tableId,
            _keyTuple,
            0,
            abi.encodePacked((amount))
        );
        // StoreSwitch.setField(
        //     _tableId,
        //     _keyTuple,
        //     0,
        //     abi.encodePacked((amount))
        // );
    }

    /** Get amount */
    function get(address owner) internal view returns (uint256 amount) {
        bytes32[] memory _keyTuple = new bytes32[](2);
        _keyTuple[0] = bytes32(uint256(uint160((owner))));

        // bytes memory _blob = StoreSwitch.getField(_tableId, _keyTuple, 0);
        // return (uint32(Bytes.slice4(_blob, 0)));
    }
}
