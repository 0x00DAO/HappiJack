// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IComponent {
    function getRoot() external view returns (address);

    function getId() external view returns (uint256);

    function isComponent() external pure returns (bool);
}
