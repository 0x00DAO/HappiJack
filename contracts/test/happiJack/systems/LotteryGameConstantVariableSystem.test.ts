import { expect } from 'chai';
import { BigNumber, Contract } from 'ethers';
import { ethers, upgrades } from 'hardhat';
import { gameDeploy } from '../../../scripts/consts/deploy.game.const';
import { eonTestUtil } from '../../../scripts/eno/eonTest.util';

describe('LotteryGameConstantVariableSystem', function () {
  let gameRootContract: Contract;
  let lotteryGameSystem: Contract;
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

  describe('setGameConfig', function () {
    const configId = ethers.utils.id('lotteryGame');
    it('should set game config', async function () {
      await lotteryGameConstantVariableSystem[
        'setGameConfig(uint256,uint256,uint256)'
      ](configId, 1, 0);

      const gameConfig = await lotteryGameConstantVariableSystem[
        'getGameConfig(uint256)'
      ](configId);
      expect(gameConfig).to.equal(1);

      await lotteryGameConstantVariableSystem[
        'setGameConfig(uint256,uint256,uint256)'
      ](configId, 2, 1);

      const gameConfig2 = await lotteryGameConstantVariableSystem[
        'getGameConfig(uint256)'
      ](configId);
      expect(gameConfig2).to.equal(2);
    });

    it('fail: old value is not equal to current value', async function () {
      await lotteryGameConstantVariableSystem[
        'setGameConfig(uint256,uint256,uint256)'
      ](configId, 1, 0);

      await expect(
        lotteryGameConstantVariableSystem[
          'setGameConfig(uint256,uint256,uint256)'
        ](configId, 2, 0)
      ).to.be.revertedWith('old value is not equal to current value');
    });
  });

  describe('configKey', function () {
    it('should return config key', async function () {
      const configId = ethers.utils.id('lotteryGame');
      const configKey = await lotteryGameConstantVariableSystem.configKey(
        'lotteryGame'
      );
      expect(configKey).to.equal(configId);
    });
  });
});
