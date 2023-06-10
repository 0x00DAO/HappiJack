import { expect } from 'chai';
import { BigNumber, Contract } from 'ethers';
import { ethers, upgrades } from 'hardhat';
import { gameDeploy } from '../../../scripts/consts/deploy.game.const';
import { eonTestUtil } from '../../../scripts/eno/eonTest.util';

describe('LotteryGameLotteryCoreSystem', function () {
  let gameRootContract: Contract;
  let lotteryGameSystem: Contract;
  let lotteryGameLotteryCoreSystem: Contract;

  beforeEach(async function () {
    //deploy GameRoot
    const GameRoot = await ethers.getContractFactory('GameRoot');
    gameRootContract = await upgrades.deployProxy(GameRoot, []);
    await gameRootContract.deployed();

    //deploy
    const systems = gameDeploy.systems;
    for (let i = 0; i < systems.length; i++) {
      await eonTestUtil.deploySystem(gameRootContract, systems[i]);
    }

    lotteryGameLotteryCoreSystem = await eonTestUtil.getSystem(
      gameRootContract,
      'LotteryGameLotteryCoreSystem',
      gameDeploy.systemIdPrefix
    );
  });

  async function createLotteryGame(): Promise<BigNumber> {
    const [owner] = await ethers.getSigners();

    const startTime = Math.floor(Date.now() / 1000); // current time
    const during = 60 * 60 * 24 * 1; // 1 days
    const endTime = startTime + during;

    const initialAmount = ethers.utils.parseEther('0.005');

    lotteryGameSystem = await eonTestUtil.getSystem(
      gameRootContract,
      'LotteryGameSystem',
      gameDeploy.systemIdPrefix
    );
    // const ownerFeeRate = 10;
    // create a lottery game
    let lotteryGameId = ethers.BigNumber.from(0);
    await expect(
      lotteryGameSystem.createLotteryGame(
        `It's a lottery game`,
        startTime,
        during,
        {
          value: initialAmount,
        }
      )
    )
      .to.emit(lotteryGameSystem, 'LotteryGameCreated')
      .withArgs(
        (x: any) => {
          lotteryGameId = x;
          return true;
        },
        owner.address,
        startTime,
        endTime
      );

    return lotteryGameId;
  }

  describe('addLotteryGameLuckyNumber', function () {
    beforeEach(async function () {
      //register owner as system, so that owner can call system functions
      const [owner] = await ethers.getSigners();
      await gameRootContract.registerSystem(
        ethers.utils.id(owner.address),
        owner.address
      );
    });
    const lotteryGameId = ethers.BigNumber.from(1999999999);
    it('success', async function () {
      await lotteryGameLotteryCoreSystem.addLotteryGameLuckyNumber(
        lotteryGameId,
        ethers.BigNumber.from(1)
      );

      //check luck number count
      await lotteryGameLotteryCoreSystem
        .getLuckNumberCount(lotteryGameId, ethers.BigNumber.from(1))
        .then((res: any) => {
          expect(res).to.equal(1);
        });
      //check luck number
      await lotteryGameLotteryCoreSystem
        .getLuckNumbers(lotteryGameId)
        .then((res: any) => {
          expect(res.length).to.equal(1);
          expect(res[0]).to.equal(ethers.BigNumber.from(1));
        });

      //add another luck number
      await lotteryGameLotteryCoreSystem.addLotteryGameLuckyNumber(
        lotteryGameId,
        ethers.BigNumber.from(1)
      );
      //check luck number count
      await lotteryGameLotteryCoreSystem
        .getLuckNumberCount(lotteryGameId, ethers.BigNumber.from(1))
        .then((res: any) => {
          expect(res).to.equal(2);
        });

      //check luck number
      await lotteryGameLotteryCoreSystem
        .getLuckNumbers(lotteryGameId)
        .then((res: any) => {
          expect(res.length).to.equal(1);
          expect(res[0]).to.equal(ethers.BigNumber.from(1));
        });

      //add another luck number
      await lotteryGameLotteryCoreSystem.addLotteryGameLuckyNumber(
        lotteryGameId,
        ethers.BigNumber.from(2)
      );
      //check luck number count
      await lotteryGameLotteryCoreSystem
        .getLuckNumberCount(lotteryGameId, ethers.BigNumber.from(2))
        .then((res: any) => {
          expect(res).to.equal(1);
        });
      //check luck number
      await lotteryGameLotteryCoreSystem
        .getLuckNumbers(lotteryGameId)
        .then((res: any) => {
          expect(res.length).to.equal(2);
          expect(res[0]).to.equal(ethers.BigNumber.from(1));
          expect(res[1]).to.equal(ethers.BigNumber.from(2));
        });
    });

    it.only('success batch', async function () {
      //add 30 random luck numbers, half of them are same
      const luckNumbers = [];
      for (let i = 0; i < 30; i++) {
        luckNumbers.push(ethers.BigNumber.from(i % 15));
      }

      for (let i = 0; i < 30; i++) {
        await lotteryGameLotteryCoreSystem.addLotteryGameLuckyNumber(
          lotteryGameId,
          luckNumbers[i]
        );
      }

      //check luck number count
      for (let i = 0; i < 15; i++) {
        await lotteryGameLotteryCoreSystem
          .getLuckNumberCount(lotteryGameId, ethers.BigNumber.from(i))
          .then((res: any) => {
            expect(res).to.equal(2);
          });
      }

      //check luck number
      await lotteryGameLotteryCoreSystem
        .getLuckNumbers(lotteryGameId)
        .then((res: any) => {
          expect(res.length).to.equal(15);
          for (let i = 0; i < 15; i++) {
            expect(res[i]).to.equal(ethers.BigNumber.from(i));
          }
        });
    });
  });

  describe('add Lucky number when buy a ticket', function () {
    const ticketPrice = ethers.utils.parseEther('0.0005');
    it('success', async function () {
      const lotteryGameId = await createLotteryGame();
      const lotteryGameSellSystem = await eonTestUtil.getSystem(
        gameRootContract,
        'LotteryGameSellSystem',
        gameDeploy.systemIdPrefix
      );
      const luckyNumber = ethers.BigNumber.from(921399);
      await lotteryGameSellSystem.buyLotteryTicketETH(
        lotteryGameId,
        luckyNumber,
        {
          value: ticketPrice,
        }
      );

      // check ticket lucky number
      const lotteryGameLuckyNumTableId = ethers.utils.id(
        'tableId' + 'HappiJack' + 'LotteryGameLuckyNumTable'
      );
      let lotteryGameLuckyNumData = await gameRootContract
        .getRecord(
          lotteryGameLuckyNumTableId,
          [ethers.utils.hexZeroPad(lotteryGameId.toHexString(), 32)],
          2
        )
        .then((res: any) => {
          return {
            CurrentLuckyNumber: ethers.utils.defaultAbiCoder.decode(
              ['uint256'],
              res[0]
            )[0],
            SumLotteryTicketLuckyNumber: ethers.utils.defaultAbiCoder.decode(
              ['uint256'],
              res[1]
            )[0],
          };
        });
      expect(lotteryGameLuckyNumData.SumLotteryTicketLuckyNumber).to.equal(
        luckyNumber
      );
      expect(lotteryGameLuckyNumData.CurrentLuckyNumber)
        .to.gte(1)
        .and.lte(999999);

      //check LotteryGameLotteryCoreSystem

      await lotteryGameLotteryCoreSystem
        .getLuckNumbers(lotteryGameId)
        .then((res: any) => {
          console.log(res);
        });
    });
  });
});
