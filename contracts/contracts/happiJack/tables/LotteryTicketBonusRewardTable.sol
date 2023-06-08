// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {IStore} from "../../eon/interface/IStore.sol";
import {System} from "../../eon/System.sol";
import {StoreDelegate} from "../../eon/StoreDelegate.sol";
import {addressToEntity, entityToAddress} from "../../eon/utils.sol";

bytes32 constant _tableId = bytes32(
    keccak256(
        abi.encodePacked(
            "tableId",
            "HappiJack",
            "LotteryTicketBonusRewardTable"
        )
    )
);
uint8 constant _Columns = 5;
bytes32 constant LotteryTicketBonusRewardTableId = _tableId;

library LotteryTicketBonusRewardTable {
    /** Get the table's metadata */
    function getMetadata()
        internal
        pure
        returns (string memory, string[] memory)
    {
        string[] memory _fieldNames = new string[](_Columns);
        _fieldNames[0] = "LotteryGameId"; // uint256
        _fieldNames[1] = "IsRewardBonus"; // bool
        _fieldNames[2] = "RewardTime"; // uint256
        _fieldNames[3] = "RewardLevel"; // uint256 1: 1st, 2: 2nd, 3: 3rd ,99: no reward
        _fieldNames[4] = "RewardAmount"; // uint256

        return ("LotteryTicketBonusRewardTable", _fieldNames);
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
    function setIsRewardBonus(
        uint256 lotteryTicketId,
        bool isRewardBonus
    ) internal {
        bytes32[] memory _keyTuple = entityKeys(lotteryTicketId);

        StoreDelegate.Store().setField(
            _tableId,
            _keyTuple,
            1,
            abi.encodePacked((isRewardBonus))
        );
    }

    /** Get  */
    function getIsRewardBonus(
        uint256 lotteryTicketId
    ) internal view returns (bool isRewardBonus) {
        bytes32[] memory _keyTuple = entityKeys(lotteryTicketId);

        bytes memory _blob = StoreDelegate.Store().getField(
            _tableId,
            _keyTuple,
            1
        );
        if (_blob.length == 0) return false;

        return abi.decode(_blob, (bool));
    }

    /** Set  */
    function setRewardTime(
        uint256 lotteryTicketId,
        uint256 rewardTime
    ) internal {
        bytes32[] memory _keyTuple = entityKeys(lotteryTicketId);

        StoreDelegate.Store().setField(
            _tableId,
            _keyTuple,
            2,
            abi.encodePacked((rewardTime))
        );
    }

    /** Get  */
    function getRewardTime(
        uint256 lotteryTicketId
    ) internal view returns (uint256 rewardTime) {
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
    function setRewardLevel(
        uint256 lotteryTicketId,
        uint256 rewardLevel
    ) internal {
        bytes32[] memory _keyTuple = entityKeys(lotteryTicketId);

        StoreDelegate.Store().setField(
            _tableId,
            _keyTuple,
            3,
            abi.encodePacked((rewardLevel))
        );
    }

    /** Get  */
    function getRewardLevel(
        uint256 lotteryTicketId
    ) internal view returns (uint256 rewardLevel) {
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
    function setRewardAmount(
        uint256 lotteryTicketId,
        uint256 rewardAmount
    ) internal {
        bytes32[] memory _keyTuple = entityKeys(lotteryTicketId);

        StoreDelegate.Store().setField(
            _tableId,
            _keyTuple,
            4,
            abi.encodePacked((rewardAmount))
        );
    }

    /** Get  */
    function getRewardAmount(
        uint256 lotteryTicketId
    ) internal view returns (uint256 rewardAmount) {
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
            bool isRewardBonus,
            uint256 rewardTime,
            uint256 rewardLevel,
            uint256 rewardAmount
        )
    {
        bytes32[] memory _keyTuple = entityKeys(id);
        bytes[] memory _blobs = StoreDelegate.Store().getRecord(
            _tableId,
            _keyTuple,
            _Columns
        );

        if (_blobs[0].length == 0) return (0, false, 0, 0, 0);

        return (
            abi.decode(_blobs[0], (uint256)),
            abi.decode(_blobs[1], (bool)),
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
