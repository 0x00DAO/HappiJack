// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {IRoot} from "./IRoot.sol";

interface IComponent {
    function getRoot() external view returns (IRoot);

    function getId() external view returns (uint256);

    function isComponent() external pure returns (bool);
}
