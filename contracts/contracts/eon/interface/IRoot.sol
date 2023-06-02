// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IRootSystem {
    function registerSystemWithAddress(address systemAddress) external;

    function registerSystem(uint256 systemId, address systemAddress) external;

    function getSystemAddress(uint256 systemId) external view returns (address);

    function isSystemAddress(
        address systemAddress
    ) external view returns (bool);

    function deleteSystem(uint256 systemId) external;
}

interface IRootCall {
    /**
     * Call the system at the given namespace and name.
     * If the system is not public, the caller must have access to the namespace or name.
     */
    // function call(
    //     uint256 systemId,
    //     bytes calldata data
    // ) external payable returns (bytes memory);
}

interface IRoot is IRootSystem, IRootCall {}
