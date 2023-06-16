// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";

abstract contract GameStoreU256Set is Initializable, ContextUpgradeable {
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
     * @param entity Entity to set the value for.
     * @param value Value to set for the given entity.
     */
    function _add(
        uint256 entity,
        uint256 value
    ) internal virtual returns (bool) {
        // Store the entity's value;
        return entityToValue[entity].add(value);
    }

    /**
     * Remove the given entity from this component.
     * Registers the update in the World contract.
     * Can only be called internally (by the component or contracts deriving from it),
     * without requiring explicit write access.
     * @param entity Entity to remove from this component.
     */
    function _remove(
        uint256 entity,
        uint256 value
    ) internal virtual returns (bool) {
        // Remove the entity from the mapping
        return entityToValue[entity].remove(value);
    }

    function has(
        uint256 entity,
        uint256 value
    ) public view virtual returns (bool) {
        return entityToValue[entity].contains(value);
    }

    function length(uint256 entity) public view virtual returns (uint256) {
        return entityToValue[entity].length();
    }

    function at(
        uint256 entity,
        uint256 index
    ) public view virtual returns (uint256) {
        return entityToValue[entity].at(index);
    }

    function values(
        uint256 entity
    ) public view virtual returns (uint256[] memory) {
        return entityToValue[entity].values();
    }

    function valuesAsAddress(
        uint256 entity
    ) public view virtual returns (address[] memory) {
        uint256[] memory store = entityToValue[entity].values();
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
