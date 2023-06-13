// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {IStore} from "../../eon/interface/IStore.sol";
import {System} from "../../eon/System.sol";
import {StoreDelegate} from "../../eon/StoreDelegate.sol";
import {addressToEntity, entityToAddress} from "../../eon/utils.sol";

bytes32 constant _tableId = bytes32(
    keccak256(
        abi.encodePacked("tableId", "HappiJack", "LotteryGameConfigFeeTable")
    )
);
uint8 constant _Columns = 2;
bytes32 constant LotteryGameConfigFeeTableId = _tableId;

library LotteryGameConfigFeeTable {
    /** Get the table's metadata */
    function getMetadata()
        internal
        pure
        returns (string memory, string[] memory)
    {
        string[] memory _fieldNames = new string[](_Columns);
        _fieldNames[0] = "ownerFeeRate"; // uint256
        _fieldNames[1] = "developFeeRate"; // uint256
        _fieldNames[2] = "verifyFeeRate"; // uint256
        return ("LotteryGameConfigFeeTable", _fieldNames);
    }

    function entityKeys(
        uint256 lotteryGameId
    ) internal pure returns (bytes32[] memory) {
        bytes32[] memory _keyTuple = new bytes32[](1);
        _keyTuple[0] = bytes32(lotteryGameId);

        return _keyTuple;
    }

    /** Set  */
    function setOwnerFeeRate(
        uint256 lotteryGameId,
        uint256 ownerFeeRate
    ) internal {
        bytes32[] memory _keyTuple = entityKeys(lotteryGameId);

        StoreDelegate.Store().setField(
            _tableId,
            _keyTuple,
            0,
            abi.encodePacked((ownerFeeRate))
        );
    }

    /** Get  */
    function getOwnerFeeRate(
        uint256 lotteryGameId
    ) internal view returns (uint256 ownerFeeRate) {
        bytes32[] memory _keyTuple = entityKeys(lotteryGameId);

        bytes memory _blob = StoreDelegate.Store().getField(
            _tableId,
            _keyTuple,
            0
        );
        if (_blob.length == 0) {
            return 0;
        }
        ownerFeeRate = abi.decode(_blob, (uint256));
    }

    /** Set  */
    function setDevelopFeeRate(
        uint256 lotteryGameId,
        uint256 developFeeRate
    ) internal {
        bytes32[] memory _keyTuple = entityKeys(lotteryGameId);

        StoreDelegate.Store().setField(
            _tableId,
            _keyTuple,
            1,
            abi.encodePacked((developFeeRate))
        );
    }

    /** Get  */
    function getDevelopFeeRate(
        uint256 lotteryGameId
    ) internal view returns (uint256 developFeeRate) {
        bytes32[] memory _keyTuple = entityKeys(lotteryGameId);

        bytes memory _blob = StoreDelegate.Store().getField(
            _tableId,
            _keyTuple,
            1
        );
        if (_blob.length == 0) {
            return 0;
        }
        developFeeRate = abi.decode(_blob, (uint256));
    }

    /** Set  */
    function setVerifyFeeRate(
        uint256 lotteryGameId,
        uint256 verifyFeeRate
    ) internal {
        bytes32[] memory _keyTuple = entityKeys(lotteryGameId);

        StoreDelegate.Store().setField(
            _tableId,
            _keyTuple,
            2,
            abi.encodePacked((verifyFeeRate))
        );
    }

    /** Get  */
    function getVerifyFeeRate(
        uint256 lotteryGameId
    ) internal view returns (uint256 verifyFeeRate) {
        bytes32[] memory _keyTuple = entityKeys(lotteryGameId);

        bytes memory _blob = StoreDelegate.Store().getField(
            _tableId,
            _keyTuple,
            2
        );
        if (_blob.length == 0) {
            return 0;
        }
        verifyFeeRate = abi.decode(_blob, (uint256));
    }

    /** Get record */
    function getRecord(
        uint256 lotteryGameId
    )
        internal
        view
        returns (
            uint256 ownerFeeRate,
            uint256 developFeeRate,
            uint256 verifyFeeRate
        )
    {
        bytes32[] memory _keyTuple = entityKeys(lotteryGameId);

        bytes[] memory _blobs = StoreDelegate.Store().getRecord(
            _tableId,
            _keyTuple,
            _Columns
        );
        if (_blobs.length == 0) {
            return (0, 0, 0);
        }
        ownerFeeRate = abi.decode(_blobs[0], (uint256));
        developFeeRate = abi.decode(_blobs[1], (uint256));
        verifyFeeRate = abi.decode(_blobs[2], (uint256));
    }

    /** Has record */
    function hasRecord(uint256 lotteryGameId) internal view returns (bool) {
        bytes32[] memory _keyTuple = entityKeys(lotteryGameId);
        return StoreDelegate.Store().hasRecord(_tableId, _keyTuple);
    }

    /** Delete record */
    function deleteRecord(uint256 id) internal {
        bytes32[] memory _keyTuple = entityKeys(id);
        StoreDelegate.Store().deleteRecord(_tableId, _keyTuple, _Columns);
    }
}
