// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IStoreRead {
    // Get partial data at schema index
    function getField(
        bytes32 table,
        bytes32[] calldata key,
        uint8 columnIndex
    ) external view returns (bytes memory);

    // Get all data at schema index
    function getRecord(
        bytes32 table,
        bytes32[] calldata key,
        uint8 columnCount
    ) external view returns (bytes[] memory);

    function hasRecord(
        bytes32 table,
        bytes32[] calldata key
    ) external view returns (bool);
}

interface IStoreWrite {
    // Set partial data at schema index
    function setField(
        bytes32 table,
        bytes32[] calldata key,
        uint8 columnIndex,
        bytes calldata data
    ) external;

    // Delete record
    function deleteRecord(
        bytes32 table,
        bytes32[] calldata key,
        uint8 columnCount
    ) external;
}

interface IStore is IStoreRead, IStoreWrite {}
