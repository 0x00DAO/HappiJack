// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";
import "../contract-upgradeable/VersionUpgradeable.sol";
import {IRoot} from "./interface/IRoot.sol";

contract GameRoot is
    Initializable,
    PausableUpgradeable,
    AccessControlUpgradeable,
    UUPSUpgradeable,
    VersionUpgradeable,
    IRoot
{
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

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

    function _version() internal pure override returns (uint256) {
        return 1;
    }

    mapping(uint256 => address) internal systems;

    function registerSystem(uint256 systemId, address systemAddress) public {
        require(systems[systemId] == address(0), "System already registered");
        systems[systemId] = systemAddress;
    }

    function getSystemAddress(uint256 systemId) public view returns (address) {
        require(systems[systemId] != address(0), "System not registered");
        return systems[systemId];
    }

    function deleteSystem(
        uint256 systemId
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(systems[systemId] != address(0), "System not registered");
        delete systems[systemId];
    }
}
