// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

///@dev This is a library that contains the system config settings for the LotteryGame system.
///this is a DeveloperAddress setting, which is for sharing the profits of the LotteryGame system.
uint256 constant IdConfigDeveloperAddress = uint256(
    keccak256("happiJack.systems.config.LotteryGameConfigDeveloperAddress")
);
