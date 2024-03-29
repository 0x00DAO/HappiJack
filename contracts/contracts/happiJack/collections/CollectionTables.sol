// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {LotteryGameActiveGameCollectionTable, LotteryGameActiveGameCollectionTableId} from "./LotteryGameActiveGameCollectionTable.sol";
import {LotteryGameHistoryGameCollectionTable, LotteryGameHistoryGameCollectionTableId} from "./LotteryGameHistoryGameCollectionTable.sol";
import {LotteryGameTicketSoldCollectionTable, LotteryGameTicketSoldCollectionTableId} from "./LotteryGameTicketSoldCollectionTable.sol";
import {LotteryLuckyNumberWithGameIdCollectionTable, LotteryLuckyNumberWithGameIdCollectionTableId} from "./LotteryLuckyNumberWithGameIdCollectionTable.sol";
import {LotteryLuckyNumberWithGameIdAndWinOrderCollectionTable, LotteryLuckyNumberWithGameIdAndWinOrderCollectionTableId} from "./LotteryLuckyNumberWithGameIdAndWinOrderCollectionTable.sol";

import {LotteryTicketIdWithGameIdAndLuckyNumberCollectionTable, LotteryTicketIdWithGameIdAndLuckyNumberCollectionTableId} from "./LotteryTicketIdWithGameIdAndLuckyNumberCollectionTable.sol";
import {LotteryTicketIdWithGameIdCollectionTable, LotteryTicketIdWithGameIdCollectionTableId} from "./LotteryTicketIdWithGameIdCollectionTable.sol";
import {LotteryTicketIdWithGameIdAndBuyerAddressCollectionTable, LotteryTicketIdWithGameIdAndBuyerAddressCollectionTableId} from "./LotteryTicketIdWithGameIdAndBuyerAddressCollectionTable.sol";
