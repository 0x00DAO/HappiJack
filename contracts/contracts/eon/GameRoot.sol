// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "./utils/VersionUpgradeable.sol";

import {AddressUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import {IRoot} from "./interface/IRoot.sol";
import {IStore, StoreRecordIndex} from "./interface/IStore.sol";

import {GameStore} from "./store/GameStore.sol";
import {IComponent} from "./interface/IComponent.sol";
import {BaseComponent} from "./component/BaseComponent.sol";
import {ComponentType} from "./component/ComponentType.sol";

import {GameRootSystemsTable} from "./tables/GameRootSystemsTable.sol";
import {GameRootSystemsIndexTable} from "./tables/GameRootSystemsIndexTable.sol";

import {SYSTEM_INTERNAL_ROLE_} from "./systems/SystemAccessControl.sol";

uint256 constant ID = uint256(keccak256("game.root.id"));

contract GameRoot is
    Initializable,
    PausableUpgradeable,
    UUPSUpgradeable,
    VersionUpgradeable,
    GameStore,
    IRoot,
    IStore
{
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    bytes32 public constant ROOT_SYSTEM_ROLE = keccak256("ROOT_SYSTEM_ROLE");
    bytes32 public constant SYSTEM_INTERNAL_ROLE = SYSTEM_INTERNAL_ROLE_;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize() public initializer {
        __Pausable_init();
        __GameStore_init(ID, address(this), ComponentType.GameRoot);
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);
        _grantRole(ROOT_SYSTEM_ROLE, msg.sender);

        _grantRole(COMPONENT_WRITE_ROLE, address(this));

        __initailize();
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyRole(UPGRADER_ROLE) {}

    /// custom logic here

    function __initailize() internal {}

    function _version() internal pure override returns (uint256) {
        return 5;
    }

    /// system management

    function registerSystemWithAddress(address systemAddress) public {
        uint256 systemId = getSystemId(systemAddress);
        registerSystem(systemId, systemAddress);
    }

    function registerSystem(
        uint256 systemId,
        address systemAddress
    ) public onlyRole(ROOT_SYSTEM_ROLE) {
        require(systemAddress != address(0), "System address is zero");
        require(
            GameRootSystemsTable.get(systemId) == address(0),
            "System already registered"
        );

        GameRootSystemsTable.set(systemId, systemAddress);
        GameRootSystemsIndexTable.set(systemAddress, systemId);

        //grant system internal role
        _grantRole(SYSTEM_INTERNAL_ROLE, systemAddress);
    }

    function getSystemAddress(
        uint256 systemId
    ) external view returns (address) {
        return GameRootSystemsTable.get(systemId);
    }

    function getSystemId(
        address systemAddress
    ) internal view returns (uint256) {
        require(systemAddress != address(0), "System address is zero");
        IComponent component = IComponent(systemAddress);
        //check if systemAddress is a component
        if (!component.isComponent()) return 0;

        return component.getId();
    }

    function isSystemAddress(
        address systemAddress
    ) external view returns (bool) {
        if (systemAddress == address(0)) return false;
        uint256 systemId = GameRootSystemsIndexTable.get(systemAddress);
        if (systemId == 0) return false;
        return GameRootSystemsTable.get(systemId) == systemAddress;
    }

    function deleteSystem(
        uint256 systemId
    ) external onlyRole(ROOT_SYSTEM_ROLE) {
        address systemAddress = GameRootSystemsTable.get(systemId);
        require(systemAddress != address(0), "System not registered");

        GameRootSystemsTable.deleteRecord(systemId);
        GameRootSystemsIndexTable.deleteRecord(systemAddress);

        //revoke system internal role
        _revokeRole(SYSTEM_INTERNAL_ROLE, systemAddress);
    }

    function setField(
        bytes32 tableId,
        bytes32[] memory key,
        uint8 schemaIndex,
        bytes memory data
    ) public whenNotPaused {
        _setField(tableId, key, schemaIndex, data);
    }

    function getField(
        bytes32 tableId,
        bytes32[] memory key,
        uint8 schemaIndex
    ) public view returns (bytes memory) {
        return _getField(tableId, key, schemaIndex);
    }

    function hasRecord(
        bytes32 tableId,
        bytes32[] memory key
    ) public view returns (bool) {
        return _hasRecord(tableId, key);
    }

    function getRecord(
        bytes32 tableId,
        bytes32[] memory key,
        uint8 columnCount
    ) public view returns (bytes[] memory) {
        return _getRecord(tableId, key, columnCount);
    }

    function getRecords(
        StoreRecordIndex[] calldata recordIndices
    ) public view returns (bytes[][] memory) {
        return _getRecords(recordIndices);
    }

    function deleteRecord(
        bytes32 tableId,
        bytes32[] memory key,
        uint8 columnCount
    ) public whenNotPaused {
        _deleteRecord(tableId, key, columnCount);
    }
}
