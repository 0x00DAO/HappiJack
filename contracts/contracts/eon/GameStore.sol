// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {IRoot} from "./interface/IRoot.sol";
import {ComponentWithEntity} from "./ComponentWithEntity.sol";

uint256 constant ID = uint256(keccak256("game.gamestore.GameStore"));

uint256 constant SLOT = uint256(keccak256("game.gamestore.slot"));

contract GameStore is Initializable, ComponentWithEntity {
    /// custom logic here

    function set(uint256 entity, uint256 value) public virtual {
        set(entity, abi.encode(value));
    }

    function getValue(uint256 entity) public view virtual returns (uint256) {
        if (!has(entity)) {
            return 0;
        }
        return abi.decode(getRawValue(entity), (uint256));
    }

    function getEntityId(
        bytes32 tableId,
        bytes32[] memory key
    ) public pure returns (uint256) {
        return uint256(keccak256(abi.encode(SLOT, tableId, key)));
    }

    function _setField(
        bytes32 tableId,
        bytes32[] memory key,
        uint8 schemaIndex,
        bytes memory data
    ) internal {
        uint256 entityId = getEntityId(tableId, key);
        set(entityId, data);
    }
}
