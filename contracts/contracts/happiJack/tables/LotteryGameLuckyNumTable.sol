// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {IStore} from "../../eon/interface/IStore.sol";
import {System} from "../../eon/System.sol";
import {StoreDelegate} from "../../eon/StoreDelegate.sol";
import {addressToEntity, entityToAddress} from "../../eon/utils.sol";

bytes32 constant _tableId = bytes32(
    keccak256(
        abi.encodePacked("tableId", "HappiJack", "LotteryGameLuckyNumTable")
    )
);
uint8 constant _Columns = 2;
bytes32 constant LotteryGameLuckyNumTableId = _tableId;

library LotteryGameLuckyNumTable {
    /** Get the table's metadata */
    function getMetadata()
        internal
        pure
        returns (string memory, string[] memory)
    {
        string[] memory _fieldNames = new string[](_Columns);
        _fieldNames[0] = "CurrentNumber"; // uint256
        _fieldNames[1] = "SumLotteryTicketLuckyNumber"; // uint256

        return ("LotteryGameLuckyNumTable", _fieldNames);
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
    function setCurrentNumber(
        uint256 lotteryGameId,
        uint256 currentNumber
    ) internal {
        bytes32[] memory _keyTuple = entityKeys(lotteryGameId);

        StoreDelegate.Store().setField(
            _tableId,
            _keyTuple,
            0,
            abi.encode(currentNumber)
        );
    }

    /** Get  */
    function getCurrentNumber(
        uint256 lotteryGameId
    ) internal view returns (uint256) {
        bytes32[] memory _keyTuple = entityKeys(lotteryGameId);

        bytes memory _blob = StoreDelegate.Store().getField(
            _tableId,
            _keyTuple,
            0
        );
        if (_blob.length == 0) return 0;
        return abi.decode(_blob, (uint256));
    }

    /** Set  */
    function setSumLotteryTicketLuckyNumber(
        uint256 lotteryGameId,
        uint256 sumLotteryTicketLuckyNumber
    ) internal {
        bytes32[] memory _keyTuple = entityKeys(lotteryGameId);

        StoreDelegate.Store().setField(
            _tableId,
            _keyTuple,
            1,
            abi.encode(sumLotteryTicketLuckyNumber)
        );
    }

    /** Get  */
    function getSumLotteryTicketLuckyNumber(
        uint256 lotteryGameId
    ) internal view returns (uint256) {
        bytes32[] memory _keyTuple = entityKeys(lotteryGameId);

        bytes memory _blob = StoreDelegate.Store().getField(
            _tableId,
            _keyTuple,
            1
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
        returns (uint256 currentNumber, uint256 sumLotteryTicketLuckyNumber)
    {
        bytes32[] memory _keyTuple = entityKeys(id);
        bytes[] memory _blobs = StoreDelegate.Store().getRecord(
            _tableId,
            _keyTuple,
            _Columns
        );
        if (_blobs.length == 0) return (0, 0);
        currentNumber = abi.decode(_blobs[0], (uint256));
        sumLotteryTicketLuckyNumber = abi.decode(_blobs[1], (uint256));
    }

    /** Delete record */
    function deleteRecord(uint256 id) internal {
        bytes32[] memory _keyTuple = entityKeys(id);
        StoreDelegate.Store().deleteRecord(_tableId, _keyTuple, _Columns);
    }
}
