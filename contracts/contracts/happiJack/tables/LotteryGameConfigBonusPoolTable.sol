// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {IStore} from "../../eon/interface/IStore.sol";
import {System} from "../../eon/systems/System.sol";
import {StoreDelegate} from "../../eon/store/StoreDelegate.sol";
import {addressToEntity, entityToAddress} from "../../eon/utils/Utils.sol";

bytes32 constant _tableId = bytes32(
    keccak256(
        abi.encodePacked(
            "tableId",
            "HappiJack",
            "LotteryGameConfigBonusPoolTable"
        )
    )
);
uint8 constant _Columns = 3;
bytes32 constant LotteryGameConfigBonusPoolTableId = _tableId;

library LotteryGameConfigBonusPoolTable {
    /** Get the table's metadata */
    function getMetadata()
        internal
        pure
        returns (string memory, string[] memory)
    {
        string[] memory _fieldNames = new string[](_Columns);
        _fieldNames[0] = "TokenType"; // uint256 0 - ETH, 1 - ERC20
        _fieldNames[1] = "TokenAddress"; // address
        _fieldNames[2] = "InitialAmount"; // uint256
        return ("LotteryGameConfigBonusPoolTable", _fieldNames);
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
            abi.encodePacked((addressToEntity(tokenAddress)))
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
    function setInitialAmount(
        uint256 lotteryGameId,
        uint256 initialAmount
    ) internal {
        bytes32[] memory _keyTuple = entityKeys(lotteryGameId);

        StoreDelegate.Store().setField(
            _tableId,
            _keyTuple,
            2,
            abi.encodePacked((initialAmount))
        );
    }

    /** Get  */
    function getInitialAmount(
        uint256 lotteryGameId
    ) internal view returns (uint256 initialAmount) {
        bytes32[] memory _keyTuple = entityKeys(lotteryGameId);

        bytes memory _blob = StoreDelegate.Store().getField(
            _tableId,
            _keyTuple,
            2
        );
        initialAmount = abi.decode(_blob, (uint256));
    }

    /** Get record */
    function getRecord(
        uint256 id
    )
        internal
        view
        returns (uint256 tokenType, address tokenAddress, uint256 initialAmount)
    {
        bytes32[] memory _keyTuple = entityKeys(id);

        bytes[] memory _blob = StoreDelegate.Store().getRecord(
            _tableId,
            _keyTuple,
            _Columns
        );
        tokenType = abi.decode(_blob[0], (uint256));
        tokenAddress = entityToAddress(abi.decode(_blob[1], (uint256)));
        initialAmount = abi.decode(_blob[2], (uint256));
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
