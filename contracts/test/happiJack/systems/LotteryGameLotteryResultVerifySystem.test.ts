import { expect } from 'chai';
import { randomInt } from 'crypto';
import { BigNumber, Contract } from 'ethers';
import { ethers, upgrades } from 'hardhat';
import { gameDeploy } from '../../../scripts/consts/deploy.game.const';
import { eonTestUtil } from '../../../scripts/eno/eonTest.util';
import { getTableRecord } from '../../../scripts/game/GameTableRecord';

describe('LotteryGameLotteryResultVerifySystem', function () {
  let gameRootContract: Contract;
  let lotteryGameSystem: Contract;
  let lotteryGameSellSystem: Contract;
  let lotteryGameLotteryResultVerifySystem: Contract;
  let lotteryGameLotteryCoreSystem: Contract;
  let lotteryGameConstantVariableSystem: Contract;

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

    lotteryGameLotteryResultVerifySystem = await eonTestUtil.getSystem(
      gameRootContract,
      'LotteryGameLotteryResultVerifySystem',
      gameDeploy.systemIdPrefix
    );

    lotteryGameSellSystem = await eonTestUtil.getSystem(
      gameRootContract,
      'LotteryGameSellSystem',
      gameDeploy.systemIdPrefix
    );

    lotteryGameLotteryCoreSystem = await eonTestUtil.getSystem(
      gameRootContract,
      'LotteryGameLotteryCoreSystem',
      gameDeploy.systemIdPrefix
    );

    lotteryGameConstantVariableSystem = await eonTestUtil.getSystem(
      gameRootContract,
      'LotteryGameConstantVariableSystem',
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

  async function buyTicket(
    lotteryGameId: BigNumber,
    addr1: any
  ): Promise<[BigNumber, BigNumber]> {
    const ticketPrice = ethers.utils.parseEther('0.0005');
    const luckyNumber = ethers.BigNumber.from(randomInt(100000, 999999));
    let ticketId = ethers.BigNumber.from(0);
    await expect(
      lotteryGameSellSystem
        .connect(addr1)
        .buyLotteryTicketETH(lotteryGameId, luckyNumber, {
          value: ticketPrice,
        })
    )
      .to.emit(lotteryGameSellSystem, 'LotteryTicketBuy')
      .withArgs(
        lotteryGameId,
        addr1.address,
        (x: any) => {
          ticketId = x;
          return true;
        },
        luckyNumber
      );
    return [ticketId, luckyNumber];
  }

  describe('verify', function () {
    const ticketPrice = ethers.utils.parseEther('0.0005');
    let lotteryGameId: BigNumber;
    let snapshotId: string;
    beforeEach(async function () {
      snapshotId = await ethers.provider.send('evm_snapshot', []);
      // create a lottery game
      lotteryGameId = await createLotteryGame();
      // create block snapshot
      const [owner] = await ethers.getSigners();

      await lotteryGameConstantVariableSystem.setGameDeveloperAddress(
        owner.address
      );
    });
    afterEach(async function () {
      // revert block
      await ethers.provider.send('evm_revert', [snapshotId]);
    });

    it('failed: lottery game not ended', async function () {
      // buy ticket
      const addresses = await ethers.getSigners();
      for (let i = 0; i < addresses.length, i < 10; i++) {
        await buyTicket(lotteryGameId, addresses[i]);
      }

      // verify
      await expect(
        lotteryGameLotteryResultVerifySystem.verify(lotteryGameId)
      ).to.be.revertedWith(
        'LotteryGameLotteryResultVerifySystem: Lottery game has not ended'
      );
    });

    it('success', async function () {
      const [owner] = await ethers.getSigners();
      // buy ticket
      const addresses = await ethers.getSigners();
      const ticketIds: Map<string, BigNumber> = new Map();
      for (let i = 0; i < addresses.length, i < 11; i++) {
        const [ticketId, luckNumber] = await buyTicket(
          lotteryGameId,
          addresses[i]
        );
        ticketIds.set(ticketId.toString(), luckNumber);
      }

      // console.log(ticketIds);

      // skip to end time
      const during = 60 * 60 * 24 * 1 + 1; // 1 days
      await ethers.provider.send('evm_increaseTime', [during]);

      //get lottery bonus pool
      const lotteryPool = await getTableRecord.LotteryGameBonusPoolTable(
        gameRootContract,
        lotteryGameId
      );
      // console.log('lotteryPool:', lotteryPool);

      // verify
      await expect(lotteryGameLotteryResultVerifySystem.verify(lotteryGameId))
        .to.be.emit(
          lotteryGameLotteryResultVerifySystem,
          'LotteryGameResultVerified'
        )
        .withArgs(lotteryGameId, (x: any) => {
          // console.log('luckyNumber:', x);
          return true;
        });

      // check lottery bonus pool
      const lotteryPoolAfter = await getTableRecord.LotteryGameBonusPoolTable(
        gameRootContract,
        lotteryGameId
      );

      expect(lotteryPoolAfter.BonusAmount).to.be.equal(lotteryPool.BonusAmount);
      console.log('lotteryPoolAfter:', lotteryPoolAfter);
      expect(lotteryPoolAfter.OwnerFeeAmount).to.be.equal(0);
      expect(lotteryPoolAfter.DevelopFeeAmount).to.be.equal(0);
      expect(lotteryPoolAfter.VerifyFeeAmount).to.be.equal(0);
      expect(lotteryPoolAfter.BonusAmountWithdraw).to.be.equal(0);

      // get ticket lucky number
      for (let [ticketId, luckyNumber] of ticketIds) {
        const ticketData = await getTableRecord.LotteryTicketTable(
          gameRootContract,
          ethers.BigNumber.from(ticketId)
        );

        expect(ticketData.luckyNumber).to.be.equal(luckyNumber);
      }

      // check lottery game
      for (let [ticketId, luckyNumber] of ticketIds) {
        const order =
          await lotteryGameLotteryCoreSystem.getLotteryLuckNumberOrder(
            lotteryGameId,
            luckyNumber,
            3
          );
        // console.log(ticketId, luckyNumber, order);
      }

      //check lottery game
      const lotteryGame = await getTableRecord.LotteryGameTable(
        gameRootContract,
        lotteryGameId
      );
      // console.log('lotteryGame:', lotteryGame);
      expect(lotteryGame.Status).to.be.equal(2);
      expect(lotteryGame.Owner).to.be.equal(owner.address);
    });

    it.only('success, not sold ticket', async function () {
      const [owner] = await ethers.getSigners();

      // skip to end time
      const during = 60 * 60 * 24 * 1 + 1; // 1 days
      await ethers.provider.send('evm_increaseTime', [during]);

      //get lottery bonus pool
      const lotteryPool = await getTableRecord.LotteryGameBonusPoolTable(
        gameRootContract,
        lotteryGameId
      );
      console.log('lotteryPool:', lotteryPool);

      // verify
      await expect(lotteryGameLotteryResultVerifySystem.verify(lotteryGameId))
        .to.be.emit(
          lotteryGameLotteryResultVerifySystem,
          'LotteryGameResultVerified'
        )
        .withArgs(lotteryGameId, (x: any) => {
          // console.log('luckyNumber:', x);
          return true;
        });

      // check lottery bonus pool
      const lotteryPoolAfter = await getTableRecord.LotteryGameBonusPoolTable(
        gameRootContract,
        lotteryGameId
      );

      expect(lotteryPoolAfter.BonusAmount).to.be.equal(lotteryPool.BonusAmount);

      console.log('lotteryPoolAfter:', lotteryPoolAfter);
      expect(lotteryPoolAfter.OwnerFeeAmount).to.be.equal(0);
      expect(lotteryPoolAfter.DevelopFeeAmount).to.be.equal(0);
      expect(lotteryPoolAfter.VerifyFeeAmount).to.be.equal(0);
      expect(lotteryPoolAfter.BonusAmountWithdraw).to.be.equal(
        lotteryPoolAfter.BonusAmount
      );

      //check lottery game
      const lotteryGame = await getTableRecord.LotteryGameTable(
        gameRootContract,
        lotteryGameId
      );
      expect(lotteryGame.Status).to.be.equal(2);
      expect(lotteryGame.Owner).to.be.equal(owner.address);
    });
  });
});
