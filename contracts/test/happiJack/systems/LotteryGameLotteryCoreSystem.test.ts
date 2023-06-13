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
        ethers.BigNumber.from(1),
        3
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
        ethers.BigNumber.from(1),
        2
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
        ethers.BigNumber.from(2),
        1
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

    it('success batch', async function () {
      //add 30 random luck numbers, half of them are same
      const luckNumbers = [];
      for (let i = 0; i < 30; i++) {
        luckNumbers.push(ethers.BigNumber.from(i % 15));
      }

      for (let i = 0; i < 30; i++) {
        await lotteryGameLotteryCoreSystem.addLotteryGameLuckyNumber(
          lotteryGameId,
          luckNumbers[i],
          i
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

    it('success batch with random luck number and sort', async function () {
      //add 300 random luck numbers, luck number range is 1-999999
      const luckNumbers = [];
      for (let i = 0; i < 300; i++) {
        luckNumbers.push(Math.floor(Math.random() * 999999));
      }

      for (let i = 0; i < 300; i++) {
        await lotteryGameLotteryCoreSystem.addLotteryGameLuckyNumber(
          lotteryGameId,
          luckNumbers[i],
          i
        );
      }

      //luck number unique count
      const luckNumberUniqueCount = new Set(luckNumbers).size;

      //check luck number count

      //check luck number
      await lotteryGameLotteryCoreSystem
        .getLuckNumbers(lotteryGameId)
        .then((res: any) => {
          expect(res.length).to.equal(luckNumberUniqueCount);
        });

      //check luck number with sort
      await lotteryGameLotteryCoreSystem
        .getLuckNumbersWithSort(lotteryGameId)
        .then((res: any) => {
          expect(res.length).to.equal(luckNumberUniqueCount);
          for (let i = 0; i < luckNumberUniqueCount - 1; i++) {
            expect(res[i]).to.lessThan(res[i + 1]);
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

  describe('getLuckNumberByClosest', function () {
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
      //add 300 random luck numbers, luck number range is 1-999999
      const luckNumbers = [];
      for (let i = 0; i < 300; i++) {
        luckNumbers.push(Math.floor(Math.random() * 999999));
      }

      for (let i = 0; i < 300; i++) {
        await lotteryGameLotteryCoreSystem.addLotteryGameLuckyNumber(
          lotteryGameId,
          luckNumbers[i],
          i
        );
      }
      console.log('add luck number success');

      const luckNumber = 100000;
      //compute closest luck number
      const closestLuckNumber = luckNumbers.reduce((prev, curr) =>
        Math.abs(curr - luckNumber) < Math.abs(prev - luckNumber) ? curr : prev
      );

      // getLuckNumberByClosest
      await lotteryGameLotteryCoreSystem
        .getLuckNumberByClosest(lotteryGameId, luckNumber, 4)
        .then((res: any) => {
          expect(res.length).to.equal(4);
          expect(res[0][0]).to.equal(closestLuckNumber);
        });
    });
  });

  describe('computeLotteryResult', function () {
    beforeEach(async function () {
      //register owner as system, so that owner can call system functions
      const [owner] = await ethers.getSigners();
      await gameRootContract.registerSystem(
        ethers.utils.id(owner.address),
        owner.address
      );
    });
    const lotteryGameId = ethers.BigNumber.from(1999999999);
    it.only('success', async function () {
      //add 300 random luck numbers, luck number range is 1-999999
      const luckNumbers = [];
      for (let i = 0; i < 300; i++) {
        luckNumbers.push(Math.floor(Math.random() * 999999));
      }

      for (let i = 0; i < 300; i++) {
        await lotteryGameLotteryCoreSystem.addLotteryGameLuckyNumber(
          lotteryGameId,
          luckNumbers[i],
          i
        );
      }

      const luckNumber = 100000;

      // winnerLuckNumbers=>[[],[],[]]
      const winnerLuckNumbers = [[]];

      // getLuckNumberByClosest
      await lotteryGameLotteryCoreSystem
        .getLuckNumberByClosest(lotteryGameId, luckNumber, 3)
        .then((res: any) => {
          expect(res.length).to.equal(3);
          for (let i = 0; i < 3; i++) {
            winnerLuckNumbers[i] = res[i];
          }
        });

      //compute lottery result
      await lotteryGameLotteryCoreSystem.computeLotteryResult(
        lotteryGameId,
        luckNumber
      );

      console.log('winnerLuckNumbers', winnerLuckNumbers);

      //get lottery result ticket order

      for (let i = 0; i < 3; i++) {
        for (let j = 0; j < winnerLuckNumbers[i].length; j++) {
          await lotteryGameLotteryCoreSystem
            .getLotteryLuckNumberOrder(
              lotteryGameId,
              winnerLuckNumbers[i][j],
              4
            )
            .then((res: any) => {
              expect(res).to.equal(i);
            });
        }
      }

      //get lottery result any ticket order

      await lotteryGameLotteryCoreSystem
        .getLotteryLuckNumberOrder(lotteryGameId, 1000, 4)
        .then((res: any) => {
          expect(res).to.equal(4);
        });
    });
  });
});
