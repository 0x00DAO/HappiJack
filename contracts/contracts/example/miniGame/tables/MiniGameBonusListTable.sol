// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {IStoreU256Set} from "../../../eon/interface/IStore.sol";
import {System} from "../../../eon/System.sol";
import {StoreU256SetSystemDelegate} from "../../../eon/StoreU256SetSystemDelegate.sol";

bytes32 constant _tableId = bytes32(
    keccak256(abi.encodePacked("tableId", "MiniGameBonusListTable"))
);
bytes32 constant MiniGameBonusListTableId = _tableId;

uint256 constant IdBonusAddressList = uint256(
    keccak256("game.systems.MiniGameBonusSystem.ID_BonusAddressList")
);

library MiniGameBonusListTable {
    // /** Get the table's metadata */
    // function getMetadata()
    //     internal
    //     pure
    //     returns (string memory, string[] memory)
    // {
    //     string[] memory _fieldNames = new string[](1);
    //     _fieldNames[0] = "amount"; // uint256
    //     return ("MiniGameBonusListTable", _fieldNames);
    // }

    // function entityKeys(
    //     address owner
    // ) internal pure returns (bytes32[] memory) {
    //     bytes32[] memory _keyTuple = new bytes32[](1);
    //     _keyTuple[0] = bytes32(uint256(uint160((owner))));

    //     return _keyTuple;
    // }

    // /** Set amount */
    // function set(address owner, uint256 amount) internal {
    //     bytes32[] memory _keyTuple = entityKeys(owner);

    //     StoreDelegate.Store().setField(
    //         _tableId,
    //         _keyTuple,
    //         0,
    //         abi.encodePacked((amount))
    //     );
    // }

    // /** Get amount */
    // function get(address owner) internal view returns (uint256 amount) {
    //     bytes32[] memory _keyTuple = entityKeys(owner);

    //     bytes memory _blob = StoreDelegate.Store().getField(
    //         _tableId,
    //         _keyTuple,
    //         0
    //     );

    //     if (_blob.length == 0) return 0;
    //     return abi.decode(_blob, (uint256));
    // }

    function store() internal view returns (IStoreU256Set) {
        return StoreU256SetSystemDelegate.StoreU256();
    }

    /** Delete amount */
    // function deleteRecord(address owner) internal {
    //     bytes32[] memory _keyTuple = entityKeys(owner);
    //     StoreU256SetSystemDelegate.StoreU256().deleteRecord(
    //         _tableId,
    //         _keyTuple,
    //         1
    //     );
    // }
}
