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
        developFeeAmount = abi.decode(_blob, (uint256));
    }

    /** Get record */
    function getRecord(
        uint256 id
    )
        internal
        view
        returns (
            uint256 totalAmount,
            uint256 bonusAmount,
            uint256 ownerFeeAmount,
            uint256 developFeeAmount
        )
    {
        bytes32[] memory _keyTuple = entityKeys(id);
        bytes[] memory _blobs = StoreDelegate.Store().getRecord(
            _tableId,
            _keyTuple,
            _Columns
        );

        totalAmount = abi.decode(_blobs[0], (uint256));
        bonusAmount = abi.decode(_blobs[1], (uint256));
        ownerFeeAmount = abi.decode(_blobs[2], (uint256));
        developFeeAmount = abi.decode(_blobs[3], (uint256));
    }

    /** Delete record */
    function deleteRecord(uint256 id) internal {
        bytes32[] memory _keyTuple = entityKeys(id);
        StoreDelegate.Store().deleteRecord(_tableId, _keyTuple, _Columns);
    }
}
