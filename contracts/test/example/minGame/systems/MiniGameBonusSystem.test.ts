import { expect } from 'chai';
import { Contract } from 'ethers';
import { ethers, upgrades } from 'hardhat';
import { deployUtil } from '../../../../scripts/utils/deploy.util';

describe('MiniGameBonusSystem', function () {
  let gameRootContract: Contract;
  let miniGameBonusSystem: Contract;

  beforeEach(async function () {
    //deploy GameRoot
    const GameRoot = await ethers.getContractFactory('GameRoot');
    gameRootContract = await upgrades.deployProxy(GameRoot, []);
    await gameRootContract.deployed();

    //deploy System
    const MiniGameBonusSystem = await ethers.getContractFactory(
      'MiniGameBonusSystem'
    );
    miniGameBonusSystem = await upgrades.deployProxy(MiniGameBonusSystem, [
      gameRootContract.address,
    ]);

    const [owner] = await ethers.getSigners();
    deployUtil.gameSystemGrantInternalRole(miniGameBonusSystem, [
      owner.address,
    ]);

    //deploy entity

    await deployUtil.gameEntityGrantWriteRole(gameRootContract, [
      miniGameBonusSystem.address,
    ]);
  });
  it('should be deployed', async function () {
    expect(miniGameBonusSystem.address).to.not.equal(null);
  });

  describe('winBonus', function () {
    it('success: should be able to win bonus', async function () {
      const [owner, addr1] = await ethers.getSigners();
      const amount = ethers.utils.parseEther('1');
      await miniGameBonusSystem.winBonusExternal(addr1.address, amount);

      const getBonus = await miniGameBonusSystem.bonusOf(addr1.address);
      expect(getBonus).to.equal(amount);
    });
  });
});
