// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {IStore} from "../../eon/interface/IStore.sol";
import {System} from "../../eon/System.sol";
import {StoreDelegate} from "../../eon/StoreDelegate.sol";
import {addressToEntity, entityToAddress} from "../../eon/utils.sol";

bytes32 constant _tableId = bytes32(
    keccak256(
        abi.encodePacked("tableId", "HappiJack", "LotteryGameBonusPoolTable")
    )
);
uint8 constant _Columns = 4;
bytes32 constant LotteryGameBonusPoolTableId = _tableId;

library LotteryGameBonusPoolTable {
    /** Get the table's metadata */
    function getMetadata()
        internal
        pure
        returns (string memory, string[] memory)
    {
        string[] memory _fieldNames = new string[](_Columns);
        _fieldNames[0] = "TotalAmount"; // uint256
        _fieldNames[1] = "BonusAmount"; // uint256
        _fieldNames[2] = "OwnerFeeAmount"; // uint256
        _fieldNames[3] = "DevelopFeeAmount"; // uint256
        _fieldNames[4] = "VerifyFeeAmount"; // uint256
        return ("LotteryGameBonusPoolTable", _fieldNames);
    }

    function entityKeys(
        uint256 lotteryGameId
    ) internal pure returns (bytes32[] memory) {
        bytes32[] memory _keyTuple = new bytes32[](1);
        _keyTuple[0] = bytes32(lotteryGameId);

        return _keyTuple;
    }

    /** Set  */
    function setTotalAmount(
        uint256 lotteryGameId,
        uint256 totalAmount
    ) internal {
        bytes32[] memory _keyTuple = entityKeys(lotteryGameId);

        StoreDelegate.Store().setField(
            _tableId,
            _keyTuple,
            0,
            abi.encodePacked((totalAmount))
        );
    }

    /** Get  */
    function getTotalAmount(
        uint256 lotteryGameId
    ) internal view returns (uint256 totalAmount) {
        bytes32[] memory _keyTuple = entityKeys(lotteryGameId);

        bytes memory _blob = StoreDelegate.Store().getField(
            _tableId,
            _keyTuple,
            0
        );
        if (_blob.length == 0) return 0;
        totalAmount = abi.decode(_blob, (uint256));
    }

    /** Set  */
    function setBonusAmount(
        uint256 lotteryGameId,
        uint256 bonusAmount
    ) internal {
        bytes32[] memory _keyTuple = entityKeys(lotteryGameId);

        StoreDelegate.Store().setField(
            _tableId,
            _keyTuple,
            1,
            abi.encodePacked((bonusAmount))
        );
    }

    /** Get  */
    function getBonusAmount(
        uint256 lotteryGameId
    ) internal view returns (uint256 bonusAmount) {
        bytes32[] memory _keyTuple = entityKeys(lotteryGameId);

        bytes memory _blob = StoreDelegate.Store().getField(
            _tableId,
            _keyTuple,
            1
        );

        if (_blob.length == 0) return 0;
        bonusAmount = abi.decode(_blob, (uint256));
    }

    /** Set  */
    function setOwnerFeeAmount(
        uint256 lotteryGameId,
        uint256 ownerFeeAmount
    ) internal {
        bytes32[] memory _keyTuple = entityKeys(lotteryGameId);

        StoreDelegate.Store().setField(
            _tableId,
            _keyTuple,
            2,
            abi.encodePacked((ownerFeeAmount))
        );
    }

    /** Get  */
    function getOwnerFeeAmount(
        uint256 lotteryGameId
    ) internal view returns (uint256 ownerFeeAmount) {
        bytes32[] memory _keyTuple = entityKeys(lotteryGameId);

        bytes memory _blob = StoreDelegate.Store().getField(
            _tableId,
            _keyTuple,
            2
        );
        if (_blob.length == 0) return 0;
        ownerFeeAmount = abi.decode(_blob, (uint256));
    }

    /** Set  */
    function setDevelopFeeAmount(
        uint256 lotteryGameId,
        uint256 developFeeAmount
    ) internal {
        bytes32[] memory _keyTuple = entityKeys(lotteryGameId);

        StoreDelegate.Store().setField(
            _tableId,
            _keyTuple,
            3,
            abi.encodePacked((developFeeAmount))
        );
    }

    /** Get  */
    function getDevelopFeeAmount(
        uint256 lotteryGameId
    ) internal view returns (uint256 developFeeAmount) {
        bytes32[] memory _keyTuple = entityKeys(lotteryGameId);

        bytes memory _blob = StoreDelegate.Store().getField(
            _tableId,
            _keyTuple,
            3
        );
        if (_blob.length == 0) return 0;
        developFeeAmount = abi.decode(_blob, (uint256));
    }

    /** Set  */
    function setVerifyFeeAmount(
        uint256 lotteryGameId,
        uint256 verifyFeeAmount
    ) internal {
        bytes32[] memory _keyTuple = entityKeys(lotteryGameId);

        StoreDelegate.Store().setField(
            _tableId,
            _keyTuple,
            4,
            abi.encodePacked((verifyFeeAmount))
        );
    }

    /** Get  */
    function getVerifyFeeAmount(
        uint256 lotteryGameId
    ) internal view returns (uint256 verifyFeeAmount) {
        bytes32[] memory _keyTuple = entityKeys(lotteryGameId);

        bytes memory _blob = StoreDelegate.Store().getField(
            _tableId,
            _keyTuple,
            4
        );
        if (_blob.length == 0) return 0;
        verifyFeeAmount = abi.decode(_blob, (uint256));
    }

    /** Get record */
    function getRecord(
        uint256 lotteryGameId
    )
        internal
        view
        returns (
            uint256 totalAmount,
            uint256 bonusAmount,
            uint256 ownerFeeAmount,
            uint256 developFeeAmount,
            uint256 verifyFeeAmount
        )
    {
        bytes32[] memory _keyTuple = entityKeys(lotteryGameId);

        bytes[] memory _blobs = StoreDelegate.Store().getRecord(
            _tableId,
            _keyTuple,
            _Columns
        );

        if (_blobs[0].length == 0) return (0, 0, 0, 0, 0);
        totalAmount = abi.decode(_blobs[0], (uint256));
        bonusAmount = abi.decode(_blobs[1], (uint256));
        ownerFeeAmount = abi.decode(_blobs[2], (uint256));
        developFeeAmount = abi.decode(_blobs[3], (uint256));
        verifyFeeAmount = abi.decode(_blobs[4], (uint256));
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
