import { expect } from 'chai';
import { Contract } from 'ethers';
import { ethers, upgrades } from 'hardhat';
import { gameDeploy } from '../../../scripts/consts/deploy.game.const';
import { eonTestUtil } from '../../../scripts/eno/eonTest.util';

describe('LotteryGameSellSystem', function () {
  let gameRootContract: Contract;
  let lotteryGameSystem: Contract;
  let lotteryGameBonusPoolSystem: Contract;
  let lotteryGameTicketSystem: Contract;
  let lotteryGameLuckyNumberSystem: Contract;

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

    lotteryGameSystem = await eonTestUtil.getSystem(
      gameRootContract,
      'LotteryGameSystem',
      gameDeploy.systemIdPrefix
    );
  });

  describe('createLotteryGame', function () {
    it('success', async function () {
      const [owner] = await ethers.getSigners();

      const startTime = Math.floor(Date.now() / 1000); // current time
      const during = 60 * 60 * 24 * 1; // 1 days
      const endTime = startTime + during;

      const initialAmount = ethers.utils.parseEther('0.005');

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

      const lotteryGameData = await lotteryGameSystem.getLotteryGame(
        lotteryGameId
      );
    });
  });
});
