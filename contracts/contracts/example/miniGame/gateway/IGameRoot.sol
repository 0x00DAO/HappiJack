// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {IRoot} from "../../../eon/interface/IRoot.sol";
import {IMiniGameBonusSystem} from "../gateway/IMiniGameBonusSystem.sol";

interface IGameRoot is IRoot, IMiniGameBonusSystem {}
