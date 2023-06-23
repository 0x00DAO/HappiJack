// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {IStore} from "../../eon/interface/IStore.sol";
import {System} from "../../eon/systems/System.sol";
import {StoreDelegate} from "../../eon/store/StoreDelegate.sol";
import {addressToEntity, entityToAddress} from "../../eon/utils/Utils.sol";

bytes32 constant _tableId = bytes32(
    keccak256(
        abi.encodePacked("tableId", "HappiJack", "LotteryGameTicketTable")
    )
);
uint8 constant _Columns = 2;
bytes32 constant LotteryGameTicketTableId = _tableId;

library LotteryGameTicketTable {
    /** Get the table's metadata */
    function getMetadata()
        internal
        pure
        returns (string memory, string[] memory)
    {
        string[] memory _fieldNames = new string[](_Columns);
        _fieldNames[0] = "TicketSoldCount"; // uint256
        _fieldNames[1] = "LastSoldTicketId"; // uint256

        return ("LotteryGameTicketTable", _fieldNames);
    }

    function entityKeys(
        uint256 lotteryGameId
    ) internal pure returns (bytes32[] memory) {
        bytes32[] memory _keyTuple = new bytes32[](1);
        _keyTuple[0] = bytes32(lotteryGameId);

        return _keyTuple;
    }

    /** Has record */
    function hasRecord(uint256 lotteryGameId) internal view returns (bool) {
        bytes32[] memory _keyTuple = entityKeys(lotteryGameId);
        return StoreDelegate.Store().hasRecord(_tableId, _keyTuple);
    }

    /** Set  */
    function setTicketSoldCount(
        uint256 lotteryGameId,
        uint256 ticketSoldCount
    ) internal {
        bytes32[] memory _keyTuple = entityKeys(lotteryGameId);

        StoreDelegate.Store().setField(
            _tableId,
            _keyTuple,
            0,
            abi.encodePacked((ticketSoldCount))
        );
    }

    /** Get  */
    function getTicketSoldCount(
        uint256 lotteryGameId
    ) internal view returns (uint256 ticketSoldCount) {
        bytes32[] memory _keyTuple = entityKeys(lotteryGameId);

        bytes memory _blob = StoreDelegate.Store().getField(
            _tableId,
            _keyTuple,
            0
        );
        if (_blob.length == 0) {
            return 0;
        }

        ticketSoldCount = abi.decode(_blob, (uint256));
    }

    /** Set  */
    function setLastSoldTicketId(
        uint256 lotteryGameId,
        uint256 lastSoldTicketId
    ) internal {
        bytes32[] memory _keyTuple = entityKeys(lotteryGameId);

        StoreDelegate.Store().setField(
            _tableId,
            _keyTuple,
            1,
            abi.encodePacked((lastSoldTicketId))
        );
    }

    /** Get  */
    function getLastSoldTicketId(
        uint256 lotteryGameId
    ) internal view returns (uint256 lastSoldTicketId) {
        bytes32[] memory _keyTuple = entityKeys(lotteryGameId);

        bytes memory _blob = StoreDelegate.Store().getField(
            _tableId,
            _keyTuple,
            1
        );
        if (_blob.length == 0) {
            return 0;
        }

        lastSoldTicketId = abi.decode(_blob, (uint256));
    }

    /** Get record */
    function getRecord(
        uint256 lotteryGameId
    )
        internal
        view
        returns (uint256 ticketSoldCount, uint256 lastSoldTicketId)
    {
        bytes32[] memory _keyTuple = entityKeys(lotteryGameId);

        bytes[] memory _blobs = StoreDelegate.Store().getRecord(
            _tableId,
            _keyTuple,
            _Columns
        );
        if (_blobs.length == 0) {
            return (0, 0);
        }

        ticketSoldCount = abi.decode(_blobs[0], (uint256));
        lastSoldTicketId = abi.decode(_blobs[1], (uint256));
    }

    /** Delete record */
    function deleteRecord(uint256 id) internal {
        bytes32[] memory _keyTuple = entityKeys(id);
        StoreDelegate.Store().deleteRecord(_tableId, _keyTuple, _Columns);
    }
}
