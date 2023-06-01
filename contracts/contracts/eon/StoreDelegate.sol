// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {IStore} from "./interface/IStore.sol";
import {IComponent} from "./interface/IComponent.sol";

library StoreDelegate {
    function Store() internal view returns (IStore) {
        return IStore(address(IComponent(address(this)).getRoot()));
    }
}
