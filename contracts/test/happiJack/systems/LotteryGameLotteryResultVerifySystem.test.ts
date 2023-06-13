import { expect } from 'chai';
import { randomInt } from 'crypto';
import { BigNumber, Contract } from 'ethers';
import { ethers, upgrades } from 'hardhat';
import { gameDeploy } from '../../../scripts/consts/deploy.game.const';
import { eonTestUtil } from '../../../scripts/eno/eonTest.util';

describe('LotteryGameLotteryResultVerifySystem', function () {
  let gameRootContract: Contract;
  let lotteryGameSystem: Contract;
  let lotteryGameSellSystem: Contract;
  let lotteryGameLotteryResultVerifySystem: Contract;

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
  ): Promise<BigNumber> {
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
    return ticketId;
  }

  describe('verify', function () {
    const ticketPrice = ethers.utils.parseEther('0.0005');
    let lotteryGameId: BigNumber;
    beforeEach(async function () {
      // create a lottery game
      lotteryGameId = await createLotteryGame();
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
  });
});
