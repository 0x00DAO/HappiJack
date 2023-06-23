import { BigNumber, Contract, ethers } from 'ethers';
import { eonTestUtil } from '../eno/eonTest.util';

async function storeU256SetSystem(gameRoot: Contract): Promise<Contract> {
  return eonTestUtil.getSystem(gameRoot, 'StoreU256SetSystem', 'eno.systems');
}
function LotteryGameActiveGameCollectionTable(): [string, string] {
  const tableId = ethers.utils.id(
    'tableId' + 'HappiJack' + 'LotteryGameActiveGameCollectionTable'
  );
  const Key = ethers.utils.id('KeyActiveGameCollection');

  return [tableId, Key];
}
async function LotteryGameActiveGameCollectionTableValues(
  gameRoot: Contract
): Promise<BigNumber[]> {
  const [tableId, Key] = LotteryGameActiveGameCollectionTable();
  const store = await storeU256SetSystem(gameRoot);
  return store['values(bytes32[])']([tableId, Key]);
}
async function LotteryGameActiveGameCollectionTableLength(
  gameRoot: Contract
): Promise<BigNumber[]> {
  const [tableId, Key] = LotteryGameActiveGameCollectionTable();
  const store = await storeU256SetSystem(gameRoot);
  return store.length([tableId, Key]);
}

function LotteryGameHistoryGameCollectionTable(): [string, string] {
  const tableId = ethers.utils.id(
    'tableId' + 'HappiJack' + 'LotteryGameHistoryGameCollectionTable'
  );
  const Key = ethers.utils.id('KeyHistory');

  return [tableId, Key];
}

async function LotteryGameHistoryGameCollectionTableValues(
  gameRoot: Contract
): Promise<BigNumber[]> {
  const [tableId, Key] = LotteryGameHistoryGameCollectionTable();
  const store = await storeU256SetSystem(gameRoot);
  return store.values([tableId, Key]);
}

async function LotteryGameHistoryGameCollectionTableLength(
  gameRoot: Contract
): Promise<BigNumber> {
  const [tableId, Key] = LotteryGameHistoryGameCollectionTable();
  const store = await storeU256SetSystem(gameRoot);
  return store.length([tableId, Key]);
}

async function LotteryGameHistoryGameCollectionTableAt(
  gameRoot: Contract,
  index: number
): Promise<BigNumber> {
  const [tableId, Key] = LotteryGameHistoryGameCollectionTable();
  const store = await storeU256SetSystem(gameRoot);
  return store.at([tableId, Key], index);
}

export const GameCollectionTable = {
  LotteryGameActiveGameCollectionTable: {
    values: LotteryGameActiveGameCollectionTableValues,
    length: LotteryGameActiveGameCollectionTableLength,
  },

  LotteryGameHistoryGameCollectionTable: {
    values: LotteryGameHistoryGameCollectionTableValues,
    length: LotteryGameHistoryGameCollectionTableLength,
    at: LotteryGameHistoryGameCollectionTableAt,
  },
};
