// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {IStore} from "../../eon/interface/IStore.sol";
import {System} from "../../eon/System.sol";
import {StoreDelegate} from "../../eon/StoreDelegate.sol";
import {addressToEntity, entityToAddress} from "../../eon/utils.sol";

bytes32 constant _tableId = bytes32(
    keccak256(
        abi.encodePacked("tableId", "HappiJack", "LotteryGameConfigTicketTable")
    )
);
uint8 constant _Columns = 4;
bytes32 constant LotteryGameConfigTicketTableId = _tableId;

library LotteryGameConfigTicketTable {
    /** Get the table's metadata */
    function getMetadata()
        internal
        pure
        returns (string memory, string[] memory)
    {
        string[] memory _fieldNames = new string[](_Columns);
        _fieldNames[0] = "TokenType"; // uint256 0 - ETH, 1 - ERC20
        _fieldNames[1] = "TokenAddress"; // address
        _fieldNames[2] = "TicketPrice"; // uint256
        _fieldNames[3] = "TicketMaxCount"; // uint256

        return ("LotteryGameConfigTicketTable", _fieldNames);
    }

    function entityKeys(
        uint256 lotteryGameId
    ) internal pure returns (bytes32[] memory) {
        bytes32[] memory _keyTuple = new bytes32[](1);
        _keyTuple[0] = bytes32(lotteryGameId);

        return _keyTuple;
    }

    /** Set  */
    function setTokenType(uint256 lotteryGameId, uint256 tokenType) internal {
        bytes32[] memory _keyTuple = entityKeys(lotteryGameId);

        StoreDelegate.Store().setField(
            _tableId,
            _keyTuple,
            0,
            abi.encodePacked((tokenType))
        );
    }

    /** Get  */
    function getTokenType(
        uint256 lotteryGameId
    ) internal view returns (uint256 tokenType) {
        bytes32[] memory _keyTuple = entityKeys(lotteryGameId);

        bytes memory _blob = StoreDelegate.Store().getField(
            _tableId,
            _keyTuple,
            0
        );

        tokenType = abi.decode(_blob, (uint256));
    }

    /** Set  */
    function setTokenAddress(
        uint256 lotteryGameId,
        address tokenAddress
    ) internal {
        bytes32[] memory _keyTuple = entityKeys(lotteryGameId);

        StoreDelegate.Store().setField(
            _tableId,
            _keyTuple,
            1,
            abi.encodePacked(addressToEntity(tokenAddress))
        );
    }

    /** Get  */
    function getTokenAddress(
        uint256 lotteryGameId
    ) internal view returns (address tokenAddress) {
        bytes32[] memory _keyTuple = entityKeys(lotteryGameId);

        bytes memory _blob = StoreDelegate.Store().getField(
            _tableId,
            _keyTuple,
            1
        );
        tokenAddress = entityToAddress(abi.decode(_blob, (uint256)));
    }

    /** Set  */
    function setTicketPrice(
        uint256 lotteryGameId,
        uint256 ticketPrice
    ) internal {
        bytes32[] memory _keyTuple = entityKeys(lotteryGameId);

        StoreDelegate.Store().setField(
            _tableId,
            _keyTuple,
            2,
            abi.encodePacked((ticketPrice))
        );
    }

    /** Get  */
    function getTicketPrice(
        uint256 lotteryGameId
    ) internal view returns (uint256 ticketPrice) {
        bytes32[] memory _keyTuple = entityKeys(lotteryGameId);

        bytes memory _blob = StoreDelegate.Store().getField(
            _tableId,
            _keyTuple,
            2
        );

        ticketPrice = abi.decode(_blob, (uint256));
    }

    /** Set  */
    function setTicketMaxCount(
        uint256 lotteryGameId,
        uint256 ticketMaxCount
    ) internal {
        bytes32[] memory _keyTuple = entityKeys(lotteryGameId);

        StoreDelegate.Store().setField(
            _tableId,
            _keyTuple,
            3,
            abi.encodePacked((ticketMaxCount))
        );
    }

    /** Get  */
    function getTicketMaxCount(
        uint256 lotteryGameId
    ) internal view returns (uint256 ticketMaxCount) {
        bytes32[] memory _keyTuple = entityKeys(lotteryGameId);

        bytes memory _blob = StoreDelegate.Store().getField(
            _tableId,
            _keyTuple,
            3
        );

        ticketMaxCount = abi.decode(_blob, (uint256));
    }

    /** Get record */
    function getRecord(
        uint256 id
    ) internal view returns (uint256 ownerFeeRate, uint256 developFeeRate) {
        bytes32[] memory _keyTuple = entityKeys(id);
        bytes[] memory _blobs = StoreDelegate.Store().getRecord(
            _tableId,
            _keyTuple,
            _Columns
        );

        ownerFeeRate = abi.decode(_blobs[0], (uint256));
        developFeeRate = abi.decode(_blobs[1], (uint256));
    }

    /** Delete record */
    function deleteRecord(uint256 id) internal {
        bytes32[] memory _keyTuple = entityKeys(id);
        StoreDelegate.Store().deleteRecord(_tableId, _keyTuple, _Columns);
    }
}
