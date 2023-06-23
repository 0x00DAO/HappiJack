// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {IStoreU256Set} from "../../../eon/interface/IStore.sol";
import {StoreU256SetSystemDelegate} from "../../../eon/store/StoreU256SetSystemDelegate.sol";

bytes32 constant _tableId = bytes32(
    keccak256(abi.encodePacked("tableId", "MiniGameBonusListTable"))
);
bytes32 constant MiniGameBonusListTableId = _tableId;

uint256 constant IdBonusAddressList = uint256(
    keccak256("game.systems.MiniGameBonusSystem.ID_BonusAddressList")
);

library MiniGameBonusListTable {
    function entityKeys(
        uint256 entity
    ) internal pure returns (bytes32[] memory) {
        bytes32[] memory _keyTuple = new bytes32[](2);
        _keyTuple[0] = _tableId;
        _keyTuple[1] = bytes32(entity);
        return _keyTuple;
    }

    function add(uint256 entity, uint256 value) internal {
        bytes32[] memory _keyTuple = entityKeys(entity);
        store().add(_keyTuple, value);
    }

    function values(uint256 entity) internal view returns (uint256[] memory) {
        bytes32[] memory _keyTuple = entityKeys(entity);
        return store().values(_keyTuple);
    }

    function remove(uint256 entity, uint256 value) internal {
        bytes32[] memory _keyTuple = entityKeys(entity);
        store().remove(_keyTuple, value);
    }

    function valuesAsAddress(
        uint256 entity
    ) internal view returns (address[] memory) {
        bytes32[] memory _keyTuple = entityKeys(entity);
        return store().valuesAsAddress(_keyTuple);
    }

    function store() internal view returns (IStoreU256Set) {
        return StoreU256SetSystemDelegate.StoreU256Set();
    }
}
