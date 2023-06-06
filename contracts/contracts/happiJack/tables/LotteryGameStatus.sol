// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

enum LotteryGameStatus {
    Idle, // 0 - Idle
    Active, // 1 - Active
    Ended, // 2 - Ended (got winner)
    Canceled // 3 - Canceled
}
