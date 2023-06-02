import { expect } from 'chai';
import { Contract } from 'ethers';
import { ethers, upgrades } from 'hardhat';
import { deployUtil } from '../../../../scripts/utils/deploy.util';

describe('MiniGameBonusSystem', function () {
  let gameRootContract: Contract;
  let miniGameBonusSystem: Contract;
  let miniGameBonusSystemAgent: Contract;

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
    await deployUtil.gameRegisterSystem(
      gameRootContract,
      miniGameBonusSystem.address
    );

    //deploy Agent
    const MiniGameBonusSystemAgent = await ethers.getContractFactory(
      'MiniGameBonusSystemAgent'
    );
    miniGameBonusSystemAgent = await upgrades.deployProxy(
      MiniGameBonusSystemAgent,
      [gameRootContract.address]
    );

    //register agent
    await deployUtil.gameRegisterSystem(
      gameRootContract,
      miniGameBonusSystemAgent.address
    );
  });
  it('should be deployed', async function () {
    expect(miniGameBonusSystem.address).to.not.equal(null);
  });

  describe('winBonus', function () {
    it('success: should be able to win bonus', async function () {
      const [owner, addr1] = await ethers.getSigners();
      const amount = ethers.utils.parseEther('1');
      await miniGameBonusSystem.winBonusExternal(addr1.address, amount);

      miniGameBonusSystem.functions.winBonus(addr1.address, amount);
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

    it('success: should be able to winBonusExternalSkipRoleCheck', async function () {
      const [owner, addr1] = await ethers.getSigners();

      //register owner as system

      const amount = ethers.utils.parseEther('1');

      await miniGameBonusSystem.winBonusExternalSkipRoleCheck(
        addr1.address,
        amount
      );

      const getBonus = await miniGameBonusSystem.bonusOf(addr1.address);
      expect(getBonus).to.equal(amount);
    });
  });

  describe('GameRoot Access Control', function () {
    it('fail: should not be able to setField', async function () {
      //   function setField(
      //     bytes32 tableId,
      //     bytes32[] memory key,
      //     uint8 schemaIndex,
      //     bytes memory data
      // ) public {
      //     _setField(tableId, key, schemaIndex, data);
      // }

      const [owner, addr1] = await ethers.getSigners();
      const amount = ethers.utils.parseEther('1');
      await expect(
        gameRootContract.setField(
          ethers.utils.id(addr1.address),
          [ethers.utils.id('bonus')],
          0,
          ethers.utils.defaultAbiCoder.encode(['uint256'], [amount])
        )
      ).to.be.revertedWith(
        'AccessControl: account 0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266 is missing role 0xa839ac79d0c3dc042356f5145cc46d683e75a99618755bb05e5e2d9ba0fba12b'
      );
    });
  });

  describe('MiniGameBonusSystemAgent Access Control', function () {
    it('success: should be able to bonus', async function () {
      const [owner, addr1] = await ethers.getSigners();
      const amount = ethers.utils.parseEther('1');
      await miniGameBonusSystemAgent.winBonus(addr1.address, amount);

      const getBonus = await miniGameBonusSystem.bonusOf(addr1.address);
      expect(getBonus).to.equal(amount);
    });
  });

  describe('Call from GameRoot', function () {
    it('success: should be able to bonus(winBonusExternal)', async function () {
      const [owner, addr1] = await ethers.getSigners();
      const amount = ethers.utils.parseEther('1');

      const miniGameBonusSystemId = ethers.utils.id(
        'game.systems.MiniGameBonusSystem'
      );

      const MiniGameBonusSystem = await ethers.getContractFactory(
        'MiniGameBonusSystem'
      );
      const functionFragment =
        MiniGameBonusSystem.interface.getFunction('winBonusExternal');

      const encodeParams = MiniGameBonusSystem.interface.encodeFunctionData(
        functionFragment,
        [addr1.address, amount]
      );

      await gameRootContract.call(miniGameBonusSystemId, encodeParams);

      const getBonus = await miniGameBonusSystem.bonusOf(addr1.address);
      expect(getBonus).to.equal(amount);
    });

    it('fail: should be able to bonus', async function () {
      const [owner, addr1] = await ethers.getSigners();
      const amount = ethers.utils.parseEther('1');

      const miniGameBonusSystemId = ethers.utils.id(
        'game.systems.MiniGameBonusSystem'
      );

      const MiniGameBonusSystem = await ethers.getContractFactory(
        'MiniGameBonusSystem'
      );
      const functionFragment =
        MiniGameBonusSystem.interface.getFunction('winBonus');

      const encodeParams = MiniGameBonusSystem.interface.encodeFunctionData(
        functionFragment,
        [addr1.address, amount]
      );

      await expect(
        gameRootContract.call(miniGameBonusSystemId, encodeParams)
      ).to.be.revertedWith(
        `AccessControl: account ${gameRootContract.address.toLowerCase()} is missing role 0x7c36da28cc8d8517c2cb99d17e2a1aed66b5d8a36bf0b347bb1aebd692d0a3c7`
      );
    });
  });
});
