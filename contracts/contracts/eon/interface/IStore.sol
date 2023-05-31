// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IStoreWrite {
    // Set partial data at schema index
    function setField(
        bytes32 table,
        bytes32[] calldata key,
        uint8 schemaIndex,
        bytes calldata data
    ) external;
}
