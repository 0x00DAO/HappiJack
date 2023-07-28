// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {addressToEntity, entityToAddress} from "@zero-dao/eon/contracts/eon/utils/Utils.sol";
import {ContractUint256VariableTable} from "../tables/ContractUint256VariableTable.sol";

///@dev This is a library that contains the system config settings for the LotteryGame system.
///this is a DeveloperAddress setting, which is for sharing the profits of the LotteryGame system.
uint256 constant IdConfigDeveloperAddress = uint256(
    keccak256("happiJack.systems.config.DeveloperAddress")
);

///@dev This is a setting for the initial pool amount of the prize pool. default is 0.005 ether
uint256 constant IdConfigWinPrizeInitialPoolAmount = uint256(
    keccak256("happiJack.systems.config.WinPrizeInitialPoolAmount")
);

///@dev This is a setting for the initial ticket price of the prize pool. default is 0.0005 ether
uint256 constant IdConfigWinPrizeInitialTicketPrice = uint256(
    keccak256("happiJack.systems.config.WinPrizeInitialTicketPrice")
);

/// @dev This is a setting for win prize develop fee. default is 10%
uint256 constant IdConfigWinPrizeDevelopFee = uint256(
    keccak256("happiJack.systems.config.WinPrizeDevelopFee")
);

/// @dev This is a setting for the duration of the create game process. default is 12 hours(43200 seconds)
uint256 constant IdConfigCreateGameDurationMinSeconds = uint256(
    keccak256("happiJack.systems.config.CreateGameDurationMinSeconds")
);

/// @dev This is a setting for the duration of the create game process. default is 24 hours(86400 seconds)
uint256 constant IdConfigCreateGameDurationMaxSeconds = uint256(
    keccak256("happiJack.systems.config.CreateGameDurationMaxSeconds")
);

/// @dev This is a setting for the lucky number min value. default is 1
uint256 constant IdConfigLuckyNumberMinValue = uint256(
    keccak256("happiJack.systems.config.LuckyNumberMinValue")
);

/// @dev This is a setting for the lucky number max value. default is 999999
uint256 constant IdConfigLuckyNumberMaxValue = uint256(
    keccak256("happiJack.systems.config.LuckyNumberMaxValue")
);

library LotteryGameSystemConfigSetting {
    function DeveloperAddress() internal view returns (address) {
        return
            entityToAddress(
                ContractUint256VariableTable.get(IdConfigDeveloperAddress)
            );
    }

    function WinPrizeInitialPoolAmount() internal view returns (uint256) {
        return
            ContractUint256VariableTable.get(
                IdConfigWinPrizeInitialPoolAmount,
                0.005 ether
            );
    }

    function WinPrizeInitialTicketPrice() internal view returns (uint256) {
        return
            ContractUint256VariableTable.get(
                IdConfigWinPrizeInitialTicketPrice,
                0.0005 ether
            );
    }

    function WinPrizeDevelopFee() internal view returns (uint256) {
        return ContractUint256VariableTable.get(IdConfigWinPrizeDevelopFee, 10);
    }

    function CreateGameDurationMinSeconds() internal view returns (uint256) {
        return
            ContractUint256VariableTable.get(
                IdConfigCreateGameDurationMinSeconds,
                43200
            );
    }

    function CreateGameDurationMaxSeconds() internal view returns (uint256) {
        return
            ContractUint256VariableTable.get(
                IdConfigCreateGameDurationMaxSeconds,
                86400
            );
    }

    function LuckyNumberMinValue() internal view returns (uint256) {
        return ContractUint256VariableTable.get(IdConfigLuckyNumberMinValue, 1);
    }

    function LuckyNumberMaxValue() internal view returns (uint256) {
        return
            ContractUint256VariableTable.get(
                IdConfigLuckyNumberMaxValue,
                999999
            );
    }
}
