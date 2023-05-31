// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {IStore} from "./interface/IStore.sol";
import {BaseComponent} from "./BaseComponent.sol";

library StoreDelegate {
    function Store() internal view returns (IStore) {
        return IStore(address(BaseComponent(address(this)).getRoot()));
    }
}
