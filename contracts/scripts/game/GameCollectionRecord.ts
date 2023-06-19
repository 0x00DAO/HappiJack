import { BigNumber, Contract, ethers } from 'ethers';
import { eonTestUtil } from '../eno/eonTest.util';

async function LotteryGameActiveGameCollectionTableValue(
  gameRoot: Contract
): Promise<BigNumber[]> {
  const tableId = ethers.utils.id(
    'tableId' + 'HappiJack' + 'LotteryGameActiveGameCollectionTable'
  );
  const Key = ethers.utils.id('KeyActiveGameCollection');

  const storeU256SetSystem = await eonTestUtil.getSystem(
    gameRoot,
    'StoreU256SetSystem',
    'eno.systems'
  );
  return storeU256SetSystem.values([tableId, Key]);
}

export const GameCollectionTable = {
  LotteryGameActiveGameCollectionTable: {
    values: LotteryGameActiveGameCollectionTableValue,
  },
};
