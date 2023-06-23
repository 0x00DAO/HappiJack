// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

import "../utils/VersionUpgradeable.sol";
import {System} from "./System.sol";
import {GameStoreU256Set} from "../store/GameStoreU256Set.sol";
import {IStoreU256SetWrite} from "../interface/IStore.sol";

uint256 constant ID = uint256(keccak256("eno.systems.StoreU256SetSystem"));

contract StoreU256SetSystem is
    Initializable,
    PausableUpgradeable,
    UUPSUpgradeable,
    System,
    GameStoreU256Set,
    ReentrancyGuardUpgradeable,
    IStoreU256SetWrite,
    VersionUpgradeable
{
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address root_) public initializer {
        __Pausable_init();
        __UUPSUpgradeable_init();
        __ReentrancyGuard_init();
        __GameStoreU256Set_init();
        __System_init(ID, root_);

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);
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

    function add(
        bytes32[] calldata key,
        uint256 value
    ) public onlyRole(SYSTEM_INTERNAL_ROLE) returns (bool) {
        return _add(key, value);
    }

    function add(
        bytes32[] calldata key,
        uint256[] calldata values
    ) public onlyRole(SYSTEM_INTERNAL_ROLE) returns (bool) {
        return _add(key, values);
    }

    function remove(
        bytes32[] calldata key,
        uint256 value
    ) public onlyRole(SYSTEM_INTERNAL_ROLE) returns (bool) {
        return _remove(key, value);
    }

    function removeAll(
        bytes32[] calldata key
    ) public onlyRole(SYSTEM_INTERNAL_ROLE) {
        _removeAll(key);
    }
}
