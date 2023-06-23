// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

import {ComponentType} from "../component/ComponentType.sol";
import {BaseComponent} from "../component/BaseComponent.sol";
import {SystemAccessControl} from "./SystemAccessControl.sol";

import {IRoot} from "../interface/IRoot.sol";

contract System is
    Initializable,
    ContextUpgradeable,
    BaseComponent,
    SystemAccessControl
{
    function __System_init(
        uint256 id_,
        address root_
    ) internal onlyInitializing {
        __BaseComponent_init(id_, root_, ComponentType.System);
        __SystemAccessControl_init();
        __System_init_unchained();
    }

    function __System_init_unchained() internal onlyInitializing {}

    function getSystemAddress(
        uint256 systemId
    ) internal view returns (address) {
        return _getRoot().getSystemAddress(systemId);
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}
