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

    //register system
    await gameRootContract.registerSystemWithAddress(
      miniGameBonusSystem.address
    );

    //grant role to write
    await deployUtil.gameEntityGrantWriteRole(gameRootContract, [
      miniGameBonusSystem.address,
    ]);

    // const [owner] = await ethers.getSigners();
    // deployUtil.gameSystemGrantInternalRole(miniGameBonusSystem, [
    // owner.address,
    // ]);
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

  describe('Access Control', function () {
    it('fail: should not be able to win bonus', async function () {
      const [owner, addr1] = await ethers.getSigners();
      const amount = ethers.utils.parseEther('1');
      await expect(
        miniGameBonusSystem.winBonus(addr1.address, amount)
      ).to.be.revertedWith(
        'AccessControl: account 0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266 is missing role 0x7c36da28cc8d8517c2cb99d17e2a1aed66b5d8a36bf0b347bb1aebd692d0a3c7'
      );
    });

    it('success: should be able to win bonus', async function () {
      const [owner, addr1] = await ethers.getSigners();

      //register owner as system
      await gameRootContract.registerSystem(
        ethers.utils.id(owner.address),
        owner.address
      );
      const amount = ethers.utils.parseEther('1');
      await miniGameBonusSystem.winBonus(addr1.address, amount);

      const getBonus = await miniGameBonusSystem.bonusOf(addr1.address);
      expect(getBonus).to.equal(amount);
    });
  });
});
