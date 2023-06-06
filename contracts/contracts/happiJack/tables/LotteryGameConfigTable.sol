// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {IStore} from "../../eon/interface/IStore.sol";
import {System} from "../../eon/System.sol";
import {StoreDelegate} from "../../eon/StoreDelegate.sol";
import {addressToEntity, entityToAddress} from "../../eon/utils.sol";

bytes32 constant _tableId = bytes32(
    keccak256(
        abi.encodePacked("tableId", "HappiJack", "LotteryGameConfigTable")
    )
);
uint8 constant _Columns = 4;
bytes32 constant LotteryGameConfigTableId = _tableId;

library LotteryGameConfigTable {
    /** Get the table's metadata */
    function getMetadata()
        internal
        pure
        returns (string memory, string[] memory)
    {
        string[] memory _fieldNames = new string[](_Columns);
        _fieldNames[0] = "owner"; // address
        _fieldNames[1] = "ad"; // string
        _fieldNames[2] = "startTime"; // uint256
        _fieldNames[3] = "during"; // uint256
        return ("LotteryGameConfigTable", _fieldNames);
    }

    function entityKeys(
        uint256 lotteryGameId
    ) internal pure returns (bytes32[] memory) {
        bytes32[] memory _keyTuple = new bytes32[](1);
        _keyTuple[0] = bytes32(lotteryGameId);

        return _keyTuple;
    }

    /** Set  */
    function setOwner(uint256 lotteryGameId, address owner) internal {
        bytes32[] memory _keyTuple = entityKeys(lotteryGameId);

        StoreDelegate.Store().setField(
            _tableId,
            _keyTuple,
            0,
            abi.encodePacked((addressToEntity(owner)))
        );
    }

    /** Get  */
    function getOwner(
        uint256 lotteryGameId
    ) internal view returns (address owner) {
        bytes32[] memory _keyTuple = entityKeys(lotteryGameId);

        bytes memory _blob = StoreDelegate.Store().getField(
            _tableId,
            _keyTuple,
            0
        );

        if (_blob.length == 0) return address(0);
        return entityToAddress(abi.decode(_blob, (uint256)));
    }

    /** Set  */
    function setAd(uint256 lotteryGameId, string memory ad) internal {
        bytes32[] memory _keyTuple = entityKeys(lotteryGameId);

        StoreDelegate.Store().setField(_tableId, _keyTuple, 1, bytes((ad)));
    }

    /** Get  */
    function getAd(
        uint256 lotteryGameId
    ) internal view returns (string memory ad) {
        bytes32[] memory _keyTuple = entityKeys(lotteryGameId);

        bytes memory _blob = StoreDelegate.Store().getField(
            _tableId,
            _keyTuple,
            1
        );

        if (_blob.length == 0) return "";
        return (string(_blob));
    }

    /** Set  */
    function setStartTime(uint256 lotteryGameId, uint256 startTime) internal {
        bytes32[] memory _keyTuple = entityKeys(lotteryGameId);

        StoreDelegate.Store().setField(
            _tableId,
            _keyTuple,
            2,
            abi.encodePacked((startTime))
        );
    }

    /** Get  */
    function getStartTime(
        uint256 lotteryGameId
    ) internal view returns (uint256 startTime) {
        bytes32[] memory _keyTuple = entityKeys(lotteryGameId);

        bytes memory _blob = StoreDelegate.Store().getField(
            _tableId,
            _keyTuple,
            2
        );

        if (_blob.length == 0) return 0;
        return abi.decode(_blob, (uint256));
    }

    /** Set  */
    function setDuring(uint256 lotteryGameId, uint256 during) internal {
        bytes32[] memory _keyTuple = entityKeys(lotteryGameId);

        StoreDelegate.Store().setField(
            _tableId,
            _keyTuple,
            3,
            abi.encodePacked((during))
        );
    }

    /** Get  */
    function getDuring(
        uint256 lotteryGameId
    ) internal view returns (uint256 during) {
        bytes32[] memory _keyTuple = entityKeys(lotteryGameId);

        bytes memory _blob = StoreDelegate.Store().getField(
            _tableId,
            _keyTuple,
            3
        );

        if (_blob.length == 0) return 0;
        return abi.decode(_blob, (uint256));
    }

    function getRecord(
        uint256 lotteryGameId
    )
        internal
        view
        returns (
            address owner,
            string memory ad,
            uint256 startTime,
            uint256 during
        )
    {
        bytes32[] memory _keyTuple = entityKeys(lotteryGameId);

        bytes[] memory _blobs = StoreDelegate.Store().getRecord(
            _tableId,
            _keyTuple,
            _Columns
        );

        if (_blobs[0].length == 0) return (address(0), "", 0, 0);
        return (
            entityToAddress(abi.decode(_blobs[0], (uint256))),
            string(_blobs[1]),
            abi.decode(_blobs[2], (uint256)),
            abi.decode(_blobs[3], (uint256))
        );
    }

    /** Delete record */
    function deleteRecord(uint256 id) internal {
        bytes32[] memory _keyTuple = entityKeys(id);
        StoreDelegate.Store().deleteRecord(_tableId, _keyTuple, _Columns);
    }
}
