// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

struct StoreRecordIndex {
    bytes32 table;
    bytes32[] key;
    uint8 columnCountOrIndex;
}

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

    function getRecords(
        StoreRecordIndex[] calldata recordIndices
    ) external view returns (bytes[][] memory);

    // Check if record exists
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

interface IStoreU256SetRead {
    // Get partial data at schema index
    function at(
        bytes32[] calldata key,
        uint256 index
    ) external view returns (uint256);

    function length(bytes32[] calldata key) external view returns (uint256);

    // Get all data at schema index
    function values(
        bytes32[] calldata key
    ) external view returns (uint256[] memory);

    // Get all data at schema index, with pagination
    function values(
        bytes32[] calldata key,
        uint256 start,
        uint256 count
    ) external view returns (uint256[] memory);

    // Get all data at schema index, with multiple keys
    function values(
        bytes32[][] calldata key
    ) external view returns (uint256[][] memory);

    function valuesAsAddress(
        bytes32[] calldata key
    ) external view returns (address[] memory);

    function has(
        bytes32[] calldata key,
        uint256 value
    ) external view returns (bool);
}

interface IStoreU256SetWrite {
    // add data to last index
    function add(bytes32[] calldata key, uint256 value) external returns (bool);

    function add(
        bytes32[] calldata key,
        uint256[] calldata values
    ) external returns (bool);

    // remove data from key
    function remove(
        bytes32[] calldata key,
        uint256 value
    ) external returns (bool);

    // remove all data from key
    function removeAll(bytes32[] calldata key) external;
}

interface IStoreU256Set is IStoreU256SetRead, IStoreU256SetWrite {}
