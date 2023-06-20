// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {IStore} from "../../eon/interface/IStore.sol";
import {System} from "../../eon/System.sol";
import {StoreDelegate} from "../../eon/StoreDelegate.sol";

import {LotteryGameBonusPoolWithdrawSystem, ID as LotteryGameBonusPoolWithdrawSystemID} from "./LotteryGameBonusPoolWithdrawSystem.sol";

library GameSystems {
    function getSystemAddress(
        uint256 systemId
    ) internal view returns (address) {
        return StoreDelegate.Root().getSystemAddress(systemId);
    }

    function getLotteryGameBonusPoolWithdrawSystem()
        internal
        view
        returns (LotteryGameBonusPoolWithdrawSystem)
    {
        return
            LotteryGameBonusPoolWithdrawSystem(
                getSystemAddress(LotteryGameBonusPoolWithdrawSystemID)
            );
    }
}
