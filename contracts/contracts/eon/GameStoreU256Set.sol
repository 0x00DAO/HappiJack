// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";
import {IStoreU256SetRead} from "./interface/IStore.sol";

abstract contract GameStoreU256Set is
    Initializable,
    ContextUpgradeable,
    IStoreU256SetRead
{
    /// custom logic here
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;
    /** Mapping from entity id to value in this component */
    mapping(uint256 => EnumerableSetUpgradeable.UintSet) internal entityToValue;

    function __GameStoreU256Set_init() internal onlyInitializing {}

    function __GameStoreU256Set_init_unchained() internal initializer {}

    /**
     * Set the given component value for the given entity.
     * Registers the update in the World contract.
     * Can only be called internally (by the component or contracts deriving from it),
     * without requiring explicit write access.
     * @param key to set the value for.
     * @param value Value to set for the given entity.
     */
    function _add(
        bytes32[] calldata key,
        uint256 value
    ) internal virtual returns (bool) {
        // Store the entity's value;
        return entityToValue[getEntityId(key)].add(value);
    }

    /**
     * Remove the given entity from this component.
     * Registers the update in the World contract.
     * Can only be called internally (by the component or contracts deriving from it),
     * without requiring explicit write access.
     */
    function _remove(
        bytes32[] calldata key,
        uint256 value
    ) internal virtual returns (bool) {
        // Remove the entity from the mapping
        return entityToValue[getEntityId(key)].remove(value);
    }

    function has(
        bytes32[] calldata key,
        uint256 value
    ) public view virtual returns (bool) {
        return entityToValue[getEntityId(key)].contains(value);
    }

    function length(
        bytes32[] calldata key
    ) public view virtual returns (uint256) {
        return entityToValue[getEntityId(key)].length();
    }

    function at(
        bytes32[] calldata key,
        uint256 index
    ) public view virtual returns (uint256) {
        return entityToValue[getEntityId(key)].at(index);
    }

    function values(
        bytes32[] calldata key
    ) public view virtual returns (uint256[] memory) {
        return entityToValue[getEntityId(key)].values();
    }

    function valuesAsAddress(
        bytes32[] calldata key
    ) public view virtual returns (address[] memory) {
        uint256[] memory store = values(key);
        address[] memory addresses;

        assembly {
            addresses := store
        }

        return addresses;
    }

    // as record operations are not supported in bare component, we use a slot to store the tableId
    function getEntityId(bytes32[] memory key) public pure returns (uint256) {
        return uint256(keccak256(abi.encode(key)));
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}
