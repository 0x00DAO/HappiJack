// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";
import {IRoot} from "../../../eon/interface/IRoot.sol";
import {Component} from "../../../eon/Component.sol";
import {ComponentWithEntity} from "../../../eon/ComponentWithEntity.sol";

uint256 constant ID = uint256(keccak256("game.entities.MiniGameBonusEntity"));

contract MiniGameBonusEntity is
    Initializable,
    PausableUpgradeable,
    AccessControlUpgradeable,
    UUPSUpgradeable,
    Component,
    ComponentWithEntity
{
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address root_) public initializer {
        __Pausable_init();
        __AccessControl_init();
        __UUPSUpgradeable_init();
        __Component_init(ID, root_);

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

    function set(uint256 entity, uint256 value) public virtual {
        set(entity, abi.encode(value));
    }

    function getValue(uint256 entity) public view virtual returns (uint256) {
        if (!has(entity)) {
            return 0;
        }
        return abi.decode(getRawValue(entity), (uint256));
    }
}
