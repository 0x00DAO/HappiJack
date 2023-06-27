// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

import {BaseComponent} from "../component/BaseComponent.sol";

bytes32 constant SYSTEM_INTERNAL_ROLE_ = keccak256("SYSTEM_INTERNAL_ROLE");

contract SystemAccessControl is BaseComponent, AccessControlUpgradeable {
    bytes32 public constant SYSTEM_INTERNAL_ROLE = SYSTEM_INTERNAL_ROLE_;

    function __SystemAccessControl_init() internal onlyInitializing {
        __AccessControl_init();
    }

    function __SystemAccessControl_init_unchained() internal onlyInitializing {}

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(
        bytes32 role,
        address account
    ) public view virtual override returns (bool) {
        // check role from root
        if (AccessControlUpgradeable(getRoot()).hasRole(role, account)) {
            return true;
        }
        return AccessControlUpgradeable.hasRole(role, account);
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}
