// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IMiniGameBonusSystem {
    function winBonusExternal(address from, uint256 amount) external;
}
