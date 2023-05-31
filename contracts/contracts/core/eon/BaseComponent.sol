// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {LibComponentType} from "./LibComponentType.sol";

import {IRoot} from "./interface/IRoot.sol";

abstract contract BaseComponent is Initializable, ContextUpgradeable {
    uint256 public id;
    LibComponentType.ComponentType public componentType;
    IRoot internal root;

    // using LibComponentType for LibComponentType.ComponentType;

    function __BaseComponent_init(
        uint256 id_,
        address root_,
        LibComponentType.ComponentType componentType_
    ) internal onlyInitializing {
        __BaseComponent_init_unchained(id_, root_, componentType_);
    }

    function __BaseComponent_init_unchained(
        uint256 id_,
        address root_,
        LibComponentType.ComponentType componentType_
    ) internal onlyInitializing {
        id = id_;
        componentType = componentType_;
        root = IRoot(root_);
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}
