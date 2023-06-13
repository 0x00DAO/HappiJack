import { BigNumber, Contract, ethers } from 'ethers';

async function LotteryTicketTableGetRecord(
  gameRoot: Contract,
  ticketId: BigNumber
): Promise<{
  lotteryGameId: BigNumber;
  Owner: any;
  luckyNumber: BigNumber;
  buyTime: BigNumber;
  winStatus: BigNumber;
}> {
  const tableId = ethers.utils.id(
    'tableId' + 'HappiJack' + 'LotteryTicketTable'
  );
  const tableData = await gameRoot
    .getRecord(
      tableId,
      [
        ethers.utils.hexZeroPad(
          ethers.BigNumber.from(ticketId).toHexString(),
          32
        ),
      ],
      5
    )
    .then((res: any) => {
      return {
        lotteryGameId: ethers.utils.defaultAbiCoder.decode(
          ['uint256'],
          res[0]
        )[0],
        Owner: ethers.utils.defaultAbiCoder.decode(['address'], res[1])[0],
        luckyNumber: ethers.utils.defaultAbiCoder.decode(
          ['uint256'],
          res[2]
        )[0],
        buyTime: ethers.utils.defaultAbiCoder.decode(['uint256'], res[3])[0],
        winStatus: ethers.utils.defaultAbiCoder.decode(['uint256'], res[4])[0],
      };
    });

  return tableData;
}

export const getTableRecord = {
  LotteryTicketTable: LotteryTicketTableGetRecord,
};
