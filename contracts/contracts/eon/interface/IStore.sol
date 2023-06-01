// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IStoreRead {
    // Get partial data at schema index
    function getField(
        bytes32 table,
        bytes32[] calldata key,
        uint8 columnIndex
    ) external view returns (bytes memory);

    // Set full record (including full dynamic data)
    function deleteRecord(
        bytes32 table,
        bytes32[] memory key,
        uint8 columnCount
    ) external;
}

interface IStoreWrite {
    // Set partial data at schema index
    function setField(
        bytes32 table,
        bytes32[] calldata key,
        uint8 columnIndex,
        bytes calldata data
    ) external;
}

interface IStore is IStoreRead, IStoreWrite {}
