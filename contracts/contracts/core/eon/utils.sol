// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/** Turn an entity ID into its corresponding Ethereum address. */
function entityToAddress(uint256 entity) pure returns (address) {
    return address(uint160(entity));
}

/** Turn an Ethereum address into its corresponding entity ID. */
function addressToEntity(address addr) pure returns (uint256) {
    return uint256(uint160(addr));
}
