// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

import {IRoot} from "../interface/IRoot.sol";
import {BaseComponent} from "../component/BaseComponent.sol";
import {ComponentType} from "../component/ComponentType.sol";
import {StoreRecordIndex} from "../interface/IStore.sol";

uint256 constant ID = uint256(keccak256("game.gamestore.GameStore"));
uint256 constant SLOT = uint256(keccak256("game.gamestore.slot"));

contract GameStore is
    Initializable,
    ContextUpgradeable,
    AccessControlUpgradeable,
    BaseComponent
{
    bytes32 public constant COMPONENT_WRITE_ROLE =
        keccak256("COMPONENT_WRITE_ROLE");

    bytes32 public constant COMPONENT_READ_ROLE =
        keccak256("COMPONENT_READ_ROLE");

    /// custom logic here
    error GameStore__NotImplemented();

    /** Mapping from entity id to value in this component */
    mapping(uint256 => bytes) internal entityToValue;

    function __GameStore_init(
        uint256 id_,
        address root_,
        ComponentType componentType_
    ) internal onlyInitializing {
        __AccessControl_init();
        __BaseComponent_init(id_, root_, componentType_);
        __GameStore_init_unchained(id_, root_);
    }

    function __GameStore_init_unchained(
        uint256 id_,
        address root_
    ) internal initializer {}

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
    }

    // as record operations are not supported in bare component, we use a slot to store the tableId
    function getRecordId(
        bytes32 tableId,
        bytes32[] memory key,
        uint8 columnIndex
    ) public pure returns (uint256) {
        return uint256(keccak256(abi.encode(SLOT, tableId, key, columnIndex)));
    }

    function _setField(
        bytes32 tableId,
        bytes32[] memory key,
        uint8 columnIndex,
        bytes memory data
    ) internal {
        uint256 entityId = getRecordId(tableId, key, columnIndex);
        set(entityId, data);
    }

    function _getField(
        bytes32 tableId,
        bytes32[] memory key,
        uint8 columnIndex
    ) internal view returns (bytes memory) {
        uint256 entityId = getRecordId(tableId, key, columnIndex);
        return getRawValue(entityId);
    }

    function _hasRecord(
        bytes32 tableId,
        bytes32[] memory key
    ) internal view returns (bool) {
        uint256 entityId = getRecordId(tableId, key, 0);
        return has(entityId);
    }

    function _getRecord(
        bytes32 tableId,
        bytes32[] memory key,
        uint8 columnCount
    ) internal view returns (bytes[] memory) {
        bytes[] memory result = new bytes[](columnCount);
        for (uint8 i = 0; i < columnCount; i++) {
            result[i] = _getField(tableId, key, i);
        }
        return result;
    }

    function _getRecords(
        StoreRecordIndex[] calldata recordIndices
    ) internal view returns (bytes[][] memory) {
        bytes[][] memory result = new bytes[][](recordIndices.length);
        for (uint256 i = 0; i < recordIndices.length; i++) {
            result[i] = _getRecord(
                recordIndices[i].table,
                recordIndices[i].key,
                recordIndices[i].columnCountOrIndex
            );
        }
        return result;
    }

    function _deleteRecord(
        bytes32 tableId,
        bytes32[] memory key,
        uint8 columnCount
    ) internal {
        for (uint8 i = 0; i < columnCount; i++) {
            uint256 entityId = getRecordId(tableId, key, i);
            remove(entityId);
        }
    }
}
