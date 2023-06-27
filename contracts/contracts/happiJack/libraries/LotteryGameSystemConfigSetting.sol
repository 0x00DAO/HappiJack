// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {addressToEntity, entityToAddress} from "../../eon/utils/Utils.sol";
import {ContractUint256VariableTable} from "../tables/ContractUint256VariableTable.sol";

///@dev This is a library that contains the system config settings for the LotteryGame system.
///this is a DeveloperAddress setting, which is for sharing the profits of the LotteryGame system.
uint256 constant IdConfigDeveloperAddress = uint256(
    keccak256("happiJack.systems.config.DeveloperAddress")
);

function getConfigDeveloperAddress() view returns (address) {
    return
        entityToAddress(
            ContractUint256VariableTable.get(IdConfigDeveloperAddress)
        );
}

///@dev This is a setting for the initial pool amount of the prize pool.
uint256 constant IdConfigWinPrizeInitialPoolAmount = uint256(
    keccak256("happiJack.systems.config.WinPrizeInitialPoolAmount")
);

function getConfigWinPrizeInitialPoolAmount() view returns (uint256) {
    return
        ContractUint256VariableTable.get(
            IdConfigWinPrizeInitialPoolAmount,
            0.005 ether
        );
}

///@dev This is a setting for the initial ticket price of the prize pool.
uint256 constant IdConfigWinPrizeInitialTicketPrice = uint256(
    keccak256("happiJack.systems.config.WinPrizeInitialTicketPrice")
);

function getConfigWinPrizeInitialTicketPrice() view returns (uint256) {
    return
        ContractUint256VariableTable.get(
            IdConfigWinPrizeInitialTicketPrice,
            0.0005 ether
        );
}
