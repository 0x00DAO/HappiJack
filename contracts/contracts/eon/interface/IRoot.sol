// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IRoot {
    function registerSystemWithAddress(address systemAddress) external;

    function registerSystem(uint256 systemId, address systemAddress) external;

    function getSystemAddress(uint256 systemId) external view returns (address);

    function isSystemAddress(
        address systemAddress
    ) external view returns (bool);

    function deleteSystem(uint256 systemId) external;
}
