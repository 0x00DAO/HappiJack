// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {IStore} from "../../eon/interface/IStore.sol";
import {System} from "../../eon/System.sol";
import {StoreDelegate} from "../../eon/StoreDelegate.sol";
import {addressToEntity, entityToAddress} from "../../eon/utils.sol";

bytes32 constant _tableId = bytes32(
    keccak256(
        abi.encodePacked(
            "tableId",
            "HappiJack",
            "LotteryGameWalletSafeBoxTable"
        )
    )
);
uint8 constant _Columns = 1;
bytes32 constant LotteryGameWalletSafeBoxTableId = _tableId;

library LotteryGameWalletSafeBoxTable {
    /** Get the table's metadata */
    function getMetadata()
        internal
        pure
        returns (string memory, string[] memory)
    {
        string[] memory _fieldNames = new string[](_Columns);
        _fieldNames[0] = "Amount"; // uint256

        return ("LotteryGameWalletSafeBoxTable", _fieldNames);
    }

    function entityKeys(
        address owner,
        uint256 tokenType,
        address tokenAddress
    ) internal pure returns (bytes32[] memory) {
        bytes32[] memory _keyTuple = new bytes32[](1);
        _keyTuple[0] = bytes32(addressToEntity(owner));
        _keyTuple[1] = bytes32(tokenType);
        _keyTuple[2] = bytes32(addressToEntity(tokenAddress));

        return _keyTuple;
    }

    /** Has record */
    function hasRecord(
        address owner,
        uint256 tokenType,
        address tokenAddress
    ) internal view returns (bool) {
        bytes32[] memory _keyTuple = entityKeys(owner, tokenType, tokenAddress);
        return StoreDelegate.Store().hasRecord(_tableId, _keyTuple);
    }

    /** Set  */
    function setAmount(
        address owner,
        uint256 tokenType,
        address tokenAddress,
        uint256 amount
    ) internal {
        bytes32[] memory _keyTuple = entityKeys(owner, tokenType, tokenAddress);

        StoreDelegate.Store().setField(
            _tableId,
            _keyTuple,
            0,
            abi.encodePacked((amount))
        );
    }

    /** Get  */
    function getAmount(
        address owner,
        uint256 tokenType,
        address tokenAddress
    ) internal view returns (uint256) {
        bytes32[] memory _keyTuple = entityKeys(owner, tokenType, tokenAddress);
        bytes[] memory _blobs = StoreDelegate.Store().getRecord(
            _tableId,
            _keyTuple,
            _Columns
        );
        if (_blobs.length == 0) return 0;
        return abi.decode(_blobs[0], (uint256));
    }

    /** Get record */
    function getRecord(
        address owner,
        uint256 tokenType,
        address tokenAddress
    ) internal view returns (uint256) {
        bytes32[] memory _keyTuple = entityKeys(owner, tokenType, tokenAddress);
        bytes[] memory _blobs = StoreDelegate.Store().getRecord(
            _tableId,
            _keyTuple,
            _Columns
        );
        if (_blobs.length == 0) return 0;
        return abi.decode(_blobs[0], (uint256));
    }

    /** Delete record */
    function deleteRecord(
        address owner,
        uint256 tokenType,
        address tokenAddress
    ) internal {
        bytes32[] memory _keyTuple = entityKeys(owner, tokenType, tokenAddress);
        StoreDelegate.Store().deleteRecord(_tableId, _keyTuple, _Columns);
    }
}
