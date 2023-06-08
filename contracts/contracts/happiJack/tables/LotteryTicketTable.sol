// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {IStore} from "../../eon/interface/IStore.sol";
import {System} from "../../eon/System.sol";
import {StoreDelegate} from "../../eon/StoreDelegate.sol";
import {addressToEntity, entityToAddress} from "../../eon/utils.sol";

bytes32 constant _tableId = bytes32(
    keccak256(abi.encodePacked("tableId", "HappiJack", "LotteryTicketTable"))
);
uint8 constant _Columns = 5;
bytes32 constant LotteryTicketTableId = _tableId;

library LotteryTicketTable {
    /** Get the table's metadata */
    function getMetadata()
        internal
        pure
        returns (string memory, string[] memory)
    {
        string[] memory _fieldNames = new string[](_Columns);
        _fieldNames[0] = "lotteryGameId"; // uint256
        _fieldNames[1] = "owner"; // address
        _fieldNames[2] = "luckyNumber"; // uint256
        _fieldNames[3] = "buyTime"; // uint256
        _fieldNames[4] = "winStatus"; // uint256 (0: waiting, 1: win, 2: lose)

        return ("LotteryTicketTable", _fieldNames);
    }

    function entityKeys(
        uint256 lotteryTicketId
    ) internal pure returns (bytes32[] memory) {
        bytes32[] memory _keyTuple = new bytes32[](1);
        _keyTuple[0] = bytes32(lotteryTicketId);

        return _keyTuple;
    }

    /** Set  */
    function setLotteryGameId(
        uint256 lotteryTicketId,
        uint256 lotteryGameId
    ) internal {
        bytes32[] memory _keyTuple = entityKeys(lotteryTicketId);

        StoreDelegate.Store().setField(
            _tableId,
            _keyTuple,
            0,
            abi.encodePacked((lotteryGameId))
        );
    }

    /** Get  */
    function getLotteryGameId(
        uint256 lotteryTicketId
    ) internal view returns (uint256 lotteryGameId) {
        bytes32[] memory _keyTuple = entityKeys(lotteryTicketId);

        bytes memory _blob = StoreDelegate.Store().getField(
            _tableId,
            _keyTuple,
            0
        );
        if (_blob.length == 0) return 0;

        return abi.decode(_blob, (uint256));
    }

    /** Set  */
    function setOwner(uint256 lotteryTicketId, address owner) internal {
        bytes32[] memory _keyTuple = entityKeys(lotteryTicketId);

        StoreDelegate.Store().setField(
            _tableId,
            _keyTuple,
            1,
            abi.encodePacked((addressToEntity(owner)))
        );
    }

    /** Get  */
    function getOwner(
        uint256 lotteryTicketId
    ) internal view returns (address owner) {
        bytes32[] memory _keyTuple = entityKeys(lotteryTicketId);

        bytes memory _blob = StoreDelegate.Store().getField(
            _tableId,
            _keyTuple,
            1
        );
        if (_blob.length == 0) return address(0);

        return entityToAddress(abi.decode(_blob, (uint256)));
    }

    /** Set  */
    function setLuckyNumber(
        uint256 lotteryTicketId,
        uint256 luckyNumber
    ) internal {
        bytes32[] memory _keyTuple = entityKeys(lotteryTicketId);

        StoreDelegate.Store().setField(
            _tableId,
            _keyTuple,
            2,
            abi.encodePacked((luckyNumber))
        );
    }

    /** Get  */
    function getLuckyNumber(
        uint256 lotteryTicketId
    ) internal view returns (uint256 luckyNumber) {
        bytes32[] memory _keyTuple = entityKeys(lotteryTicketId);

        bytes memory _blob = StoreDelegate.Store().getField(
            _tableId,
            _keyTuple,
            2
        );
        if (_blob.length == 0) return 0;

        return abi.decode(_blob, (uint256));
    }

    /** Set  */
    function setBuyTime(uint256 lotteryTicketId, uint256 buyTime) internal {
        bytes32[] memory _keyTuple = entityKeys(lotteryTicketId);

        StoreDelegate.Store().setField(
            _tableId,
            _keyTuple,
            3,
            abi.encodePacked((buyTime))
        );
    }

    /** Get  */
    function getBuyTime(
        uint256 lotteryTicketId
    ) internal view returns (uint256 buyTime) {
        bytes32[] memory _keyTuple = entityKeys(lotteryTicketId);

        bytes memory _blob = StoreDelegate.Store().getField(
            _tableId,
            _keyTuple,
            3
        );
        if (_blob.length == 0) return 0;

        return abi.decode(_blob, (uint256));
    }

    /** Set  */
    function setWinStatus(uint256 lotteryTicketId, uint256 winStatus) internal {
        bytes32[] memory _keyTuple = entityKeys(lotteryTicketId);

        StoreDelegate.Store().setField(
            _tableId,
            _keyTuple,
            4,
            abi.encodePacked((winStatus))
        );
    }

    /** Get  */
    function getWinStatus(
        uint256 lotteryTicketId
    ) internal view returns (uint256 winStatus) {
        bytes32[] memory _keyTuple = entityKeys(lotteryTicketId);

        bytes memory _blob = StoreDelegate.Store().getField(
            _tableId,
            _keyTuple,
            4
        );
        if (_blob.length == 0) return 0;

        return abi.decode(_blob, (uint256));
    }

    /** Get record */

    function getRecord(
        uint256 id
    )
        internal
        view
        returns (
            uint256 lotteryGameId,
            address owner,
            uint256 luckyNumber,
            uint256 buyTime,
            uint256 winStatus
        )
    {
        bytes32[] memory _keyTuple = entityKeys(id);

        bytes[] memory _blobs = StoreDelegate.Store().getRecord(
            _tableId,
            _keyTuple,
            _Columns
        );
        if (_blobs.length == 0) return (0, address(0), 0, 0, 0);

        return (
            abi.decode(_blobs[0], (uint256)),
            entityToAddress(abi.decode(_blobs[1], (uint256))),
            abi.decode(_blobs[2], (uint256)),
            abi.decode(_blobs[3], (uint256)),
            abi.decode(_blobs[4], (uint256))
        );
    }

    /** Has record */
    function hasRecord(uint256 id) internal view returns (bool) {
        bytes32[] memory _keyTuple = entityKeys(id);
        return StoreDelegate.Store().hasRecord(_tableId, _keyTuple);
    }

    /** Delete record */
    function deleteRecord(uint256 id) internal {
        bytes32[] memory _keyTuple = entityKeys(id);
        StoreDelegate.Store().deleteRecord(_tableId, _keyTuple, _Columns);
    }
}
