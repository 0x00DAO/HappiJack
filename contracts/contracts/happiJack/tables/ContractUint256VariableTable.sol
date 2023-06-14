// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {IStore} from "../../eon/interface/IStore.sol";
import {System} from "../../eon/System.sol";
import {StoreDelegate} from "../../eon/StoreDelegate.sol";

bytes32 constant _tableId = bytes32(
    keccak256(
        abi.encodePacked("tableId", "HappiJack", "ContractUint256VariableTable")
    )
);
bytes32 constant ContractUint256VariableTableId = _tableId;

library ContractUint256VariableTable {
    /** Get the table's metadata */
    function getMetadata()
        internal
        pure
        returns (string memory, string[] memory)
    {
        string[] memory _fieldNames = new string[](1);
        _fieldNames[0] = "value"; // uint256
        return ("ContractUint256VariableTable", _fieldNames);
    }

    function entityKeys(uint256 id) internal pure returns (bytes32[] memory) {
        bytes32[] memory _keyTuple = new bytes32[](1);
        _keyTuple[0] = bytes32(id);

        return _keyTuple;
    }

    /** Set  */
    function set(uint256 id, uint256 value) internal {
        bytes32[] memory _keyTuple = entityKeys(id);

        StoreDelegate.Store().setField(
            _tableId,
            _keyTuple,
            0,
            abi.encodePacked((value))
        );
    }

    /** Get  */
    function get(uint256 id) internal view returns (uint256 amount) {
        amount = get(id, 0);
    }

    function get(
        uint256 id,
        uint256 defaultValue
    ) internal view returns (uint256 amount) {
        bytes32[] memory _keyTuple = entityKeys(id);

        bytes memory _blob = StoreDelegate.Store().getField(
            _tableId,
            _keyTuple,
            0
        );

        if (_blob.length == 0) return defaultValue;
        return abi.decode(_blob, (uint256));
    }

    /** Delete record */
    function deleteRecord(uint256 id) internal {
        bytes32[] memory _keyTuple = entityKeys(id);
        StoreDelegate.Store().deleteRecord(_tableId, _keyTuple, 1);
    }
}
