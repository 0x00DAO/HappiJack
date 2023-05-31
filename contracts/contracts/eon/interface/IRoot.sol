// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IRoot {
    function registerSystem(uint256 systemId, address systemAddress) external;

    function getSystemAddress(uint256 systemId) external view returns (address);
}
