// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {IStore} from "../interface/IStore.sol";
import {IComponent} from "../interface/IComponent.sol";
import {IRoot} from "../interface/IRoot.sol";

library StoreDelegate {
    function Store() internal view returns (IStore) {
        return IStore(IComponent(address(this)).getRoot());
    }

    function Root() internal view returns (IRoot) {
        return IRoot(IComponent(address(this)).getRoot());
    }
}
