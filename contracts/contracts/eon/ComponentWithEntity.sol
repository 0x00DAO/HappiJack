// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {LibComponentType} from "./LibComponentType.sol";
import {Component} from "./Component.sol";

import {IRoot} from "./interface/IRoot.sol";

contract ComponentWithEntity is
    Initializable,
    ContextUpgradeable,
    AccessControlUpgradeable,
    Component
{
    error ComponentWithEntity__NotImplemented();

    /** Mapping from entity id to value in this component */
    mapping(uint256 => bytes) internal entityToValue;

    /**
     * Set the given component value for the given entity.
     * Registers the update in the World contract.
     * Can only be called by addresses with write access to this component.
     * @param entity Entity to set the value for.
     * @param value Value to set for the given entity.
     */

    function set(
        uint256 entity,
        bytes memory value
    ) public onlyRole(COMPONENT_WRITE_ROLE) {
        _set(entity, value);
    }

    /**
     * Remove the given entity from this component.
     * Registers the update in the World contract.
     * Can only be called by addresses with write access to this component.
     * @param entity Entity to remove from this component.
     */
    function remove(uint256 entity) public onlyRole(COMPONENT_WRITE_ROLE) {
        _remove(entity);
    }

    /**
     * Check whether the given entity has a value in this component.
     * @param entity Entity to check whether it has a value in this component for.
     */
    function has(uint256 entity) public view virtual returns (bool) {
        return entityToValue[entity].length != 0;
    }

    /**
     * Get the raw (abi-encoded) value of the given entity in this component.
     * @param entity Entity to get the raw value in this component for.
     */
    function getRawValue(
        uint256 entity
    ) public view virtual returns (bytes memory) {
        // Return the entity's component value
        return entityToValue[entity];
    }

    /** Not implemented in BareComponent */
    function getEntities() public view virtual returns (uint256[] memory) {
        revert ComponentWithEntity__NotImplemented();
    }

    /** Not implemented in BareComponent */
    function getEntitiesWithValue(
        bytes memory
    ) public view virtual returns (uint256[] memory) {
        revert ComponentWithEntity__NotImplemented();
    }

    /**
     * Set the given component value for the given entity.
     * Registers the update in the World contract.
     * Can only be called internally (by the component or contracts deriving from it),
     * without requiring explicit write access.
     * @param entity Entity to set the value for.
     * @param value Value to set for the given entity.
     */
    function _set(uint256 entity, bytes memory value) internal virtual {
        // Store the entity's value;
        entityToValue[entity] = value;
    }

    /**
     * Remove the given entity from this component.
     * Registers the update in the World contract.
     * Can only be called internally (by the component or contracts deriving from it),
     * without requiring explicit write access.
     * @param entity Entity to remove from this component.
     */
    function _remove(uint256 entity) internal virtual {
        // Remove the entity from the mapping
        delete entityToValue[entity];

        // Emit global event
        // IWorld(world).registerComponentValueRemoved(entity);
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}
