// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";
import "../core/contract-upgradeable/VersionUpgradeable.sol";
import {IRoot} from "./interface/IRoot.sol";
import {IStore} from "./interface/IStore.sol";

import {GameStore} from "./GameStore.sol";
import {BaseComponent} from "./BaseComponent.sol";

import {LibComponentType} from "./LibComponentType.sol";

import {SYSTEM_INTERNAL_ROLE_} from "./SystemAccessControl.sol";

uint256 constant ID = uint256(keccak256("game.root.id"));

contract GameRoot is
    Initializable,
    PausableUpgradeable,
    AccessControlUpgradeable,
    UUPSUpgradeable,
    VersionUpgradeable,
    GameStore,
    IRoot,
    IStore
{
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    bytes32 public constant SYSTEM_INTERNAL_ROLE = SYSTEM_INTERNAL_ROLE_;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize() public initializer {
        __Pausable_init();
        __AccessControl_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);

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

    mapping(uint256 => address) internal systems;
    mapping(address => uint256) internal systemIds;

    function __initailize() internal {
        __Component_init(ID, address(0));
        root = this;
    }

    function _version() internal pure override returns (uint256) {
        return 1;
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(
        bytes32 role,
        address account
    ) public view virtual override returns (bool) {
        if (
            role == SYSTEM_INTERNAL_ROLE && getRoot().isSystemAddress(account)
        ) {
            return true;
        }
        return AccessControlUpgradeable.hasRole(role, account);
    }

    function registerSystemWithAddress(
        address systemAddress
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(systemAddress != address(0), "System address is zero");
        BaseComponent component = BaseComponent(systemAddress);
        require(
            component.componentType() == LibComponentType.ComponentType.System,
            "Not a system"
        );
        uint256 systemId = component.id();
        registerSystem(systemId, systemAddress);
    }

    function registerSystem(
        uint256 systemId,
        address systemAddress
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(systemAddress != address(0), "System address is zero");
        require(systems[systemId] == address(0), "System already registered");

        systems[systemId] = systemAddress;
        systemIds[systemAddress] = systemId;
    }

    function getSystemAddress(
        uint256 systemId
    ) external view returns (address) {
        return systems[systemId];
    }

    function isSystemAddress(
        address systemAddress
    ) external view returns (bool) {
        return systemIds[systemAddress] != 0;
    }

    function deleteSystem(
        uint256 systemId
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(systems[systemId] != address(0), "System not registered");
        address systemAddress = systems[systemId];
        delete systems[systemId];
        delete systemIds[systemAddress];
    }

    function setField(
        bytes32 tableId,
        bytes32[] memory key,
        uint8 schemaIndex,
        bytes memory data
    ) public onlyRole(SYSTEM_INTERNAL_ROLE) {
        _setField(tableId, key, schemaIndex, data);
    }

    function getField(
        bytes32 tableId,
        bytes32[] memory key,
        uint8 schemaIndex
    ) public view returns (bytes memory) {
        return _getField(tableId, key, schemaIndex);
    }
}
