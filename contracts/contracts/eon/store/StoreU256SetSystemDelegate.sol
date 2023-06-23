// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {IStoreU256Set} from "../interface/IStore.sol";
import {IComponent} from "../interface/IComponent.sol";
import {IRoot} from "../interface/IRoot.sol";
import {StoreU256SetSystem, ID as StoreU256SetSystemID} from "../systems/StoreU256SetSystem.sol";

library StoreU256SetSystemDelegate {
    function StoreU256Set() internal view returns (IStoreU256Set) {
        return
            IStoreU256Set(
                IRoot(IComponent(address(this)).getRoot()).getSystemAddress(
                    StoreU256SetSystemID
                )
            );
    }
}
