// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {LibComponentType} from "./LibComponentType.sol";
import {BaseComponent} from "./BaseComponent.sol";

import {IRoot} from "./interface/IRoot.sol";

contract System is Initializable, ContextUpgradeable, BaseComponent {
    bytes32 public constant SYSTEM_INTERNAL_ROLE =
        keccak256("SYSTEM_INTERNAL_ROLE");

    function __System_init(
        uint256 id_,
        address root_
    ) internal onlyInitializing {
        __BaseComponent_init(id_, root_, LibComponentType.ComponentType.System);
        __System_init_unchained();
    }

    function __System_init_unchained() internal onlyInitializing {
        if (address(root) != address(0)) {
            root.registerSystem(id, address(this));
        }
    }

    function registerToRoot(address root_) internal {
        if (root_ == address(0)) {
            root = IRoot(root_);
        }
        root.registerSystem(id, address(this));
    }

    function getSystemAddress(
        uint256 systemId
    ) internal view returns (address) {
        return root.getSystemAddress(systemId);
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}
