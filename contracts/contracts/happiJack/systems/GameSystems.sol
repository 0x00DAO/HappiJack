// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {IStore} from "@zero-dao/eon/contracts/eon/interface/IStore.sol";
import {System} from "@zero-dao/eon/contracts/eon/systems/System.sol";
import {StoreDelegate} from "@zero-dao/eon/contracts/eon/store/StoreDelegate.sol";

import {LotteryGameSystemConfig, ID as LotteryGameSystemConfigID} from "./LotteryGameSystemConfig.sol";
import {LotteryGameConstantVariableSystem, ID as LotteryGameConstantVariableSystemID} from "./LotteryGameConstantVariableSystem.sol";
import {LotteryGameBonusPoolWithdrawSystem, ID as LotteryGameBonusPoolWithdrawSystemID} from "./LotteryGameBonusPoolWithdrawSystem.sol";
import {LotteryGameTicketBonusRewardSystem, ID as LotteryGameTicketBonusRewardSystemID} from "./LotteryGameTicketBonusRewardSystem.sol";
import {LotteryGameLotteryWalletSafeBoxSystem, ID as LotteryGameLotteryWalletSafeBoxSystemID} from "./LotteryGameLotteryWalletSafeBoxSystem.sol";
import {LotteryGameTicketNFTSystem, ID as LotteryGameTicketNFTSystemID} from "./LotteryGameTicketNFTSystem.sol";

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

    function getLotteryGameConstantVariableSystem()
        internal
        view
        returns (LotteryGameConstantVariableSystem)
    {
        return
            LotteryGameConstantVariableSystem(
                getSystemAddress(LotteryGameConstantVariableSystemID)
            );
    }

    function getLotteryGameSystemConfig()
        internal
        view
        returns (LotteryGameSystemConfig)
    {
        return
            LotteryGameSystemConfig(
                getSystemAddress(LotteryGameSystemConfigID)
            );
    }

    function getLotteryGameTicketBonusRewardSystem()
        internal
        view
        returns (LotteryGameTicketBonusRewardSystem)
    {
        return
            LotteryGameTicketBonusRewardSystem(
                getSystemAddress(LotteryGameTicketBonusRewardSystemID)
            );
    }

    function getLotteryGameLotteryWalletSafeBoxSystem()
        internal
        view
        returns (LotteryGameLotteryWalletSafeBoxSystem)
    {
        return
            LotteryGameLotteryWalletSafeBoxSystem(
                getSystemAddress(LotteryGameLotteryWalletSafeBoxSystemID)
            );
    }

    function getLotteryGameTicketNFTSystem()
        internal
        view
        returns (LotteryGameTicketNFTSystem)
    {
        return
            LotteryGameTicketNFTSystem(
                getSystemAddress(LotteryGameTicketNFTSystemID)
            );
    }
}
