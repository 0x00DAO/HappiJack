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

async function LotteryGameBonusPoolTableGetRecord(
  gameRoot: Contract,
  lotteryGameId: BigNumber
): Promise<{
  TotalAmount: BigNumber;
  BonusAmount: BigNumber;
  OwnerFeeAmount: BigNumber;
  DevelopFeeAmount: BigNumber;
  VerifyFeeAmount: BigNumber;
  BonusAmountWithdraw: BigNumber;
}> {
  const tableId = ethers.utils.id(
    'tableId' + 'HappiJack' + 'LotteryGameBonusPoolTable'
  );
  const tableData = await gameRoot
    .getRecord(
      tableId,
      [
        ethers.utils.hexZeroPad(
          ethers.BigNumber.from(lotteryGameId).toHexString(),
          32
        ),
      ],
      6
    )
    .then((res: any) => {
      return {
        TotalAmount: ethers.utils.defaultAbiCoder.decode(
          ['uint256'],
          res[0]
        )[0],
        BonusAmount: ethers.utils.defaultAbiCoder.decode(
          ['uint256'],
          res[1]
        )[0],
        OwnerFeeAmount: ethers.utils.defaultAbiCoder.decode(
          ['uint256'],
          res[2]
        )[0],
        DevelopFeeAmount: ethers.utils.defaultAbiCoder.decode(
          ['uint256'],
          res[3]
        )[0],
        VerifyFeeAmount: ethers.utils.defaultAbiCoder.decode(
          ['uint256'],
          res[4]
        )[0],
        BonusAmountWithdraw: ethers.utils.defaultAbiCoder.decode(
          ['uint256'],
          res[5]
        )[0],
      };
    });

  return tableData;
}

async function LotteryGameWalletSafeBoxTableGetRecord(
  gameRoot: Contract,
  owner: string,
  tokenType: BigNumber,
  tokenAddress: string
): Promise<{
  Amount: BigNumber;
}> {
  const tableId = ethers.utils.id(
    'tableId' + 'HappiJack' + 'LotteryGameWalletSafeBoxTable'
  );
  const tableData = await gameRoot
    .getRecord(
      tableId,
      [
        ethers.utils.hexZeroPad(ethers.BigNumber.from(owner).toHexString(), 32),
        ethers.utils.hexZeroPad(
          ethers.BigNumber.from(tokenType).toHexString(),
          32
        ),
        ethers.utils.hexZeroPad(
          ethers.BigNumber.from(tokenAddress).toHexString(),
          32
        ),
      ],
      1
    )
    .then((res: any) => {
      return {
        Amount: ethers.utils.defaultAbiCoder.decode(['uint256'], res[0])[0],
      };
    });

  return tableData;
}

export const getTableRecord = {
  LotteryTicketTable: LotteryTicketTableGetRecord,
  LotteryGameBonusPoolTable: LotteryGameBonusPoolTableGetRecord,
  LotteryGameWalletSafeBoxTable: LotteryGameWalletSafeBoxTableGetRecord,
};
