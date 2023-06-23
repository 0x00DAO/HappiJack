import { expect } from 'chai';
import { Contract } from 'ethers';
import { ethers, upgrades } from 'hardhat';
import { deployUtil } from '../../../../scripts/utils/deploy.util';

describe('MiniGameBonusSystem', function () {
  let gameRootContract: Contract;
  let miniGameBonusSystem: Contract;
  let miniGameBonusSystemAgent: Contract;
  let storeU256SetSystem: Contract;

  async function deploySystem(
    gameRoot: Contract,
    contractName: string
  ): Promise<Contract> {
    //deploy Agent
    const SystemContract = await ethers.getContractFactory(contractName);
    const systemContract = await upgrades.deployProxy(SystemContract, [
      gameRoot.address,
    ]);
    //register system
    await deployUtil.gameRegisterSystem(gameRoot, systemContract.address);
    return systemContract;
  }

  beforeEach(async function () {
    //deploy GameRoot
    const GameRoot = await ethers.getContractFactory('GameRoot');
    gameRootContract = await upgrades.deployProxy(GameRoot, []);
    await gameRootContract.deployed();

    //deploy MiniGameBonusSystem
    miniGameBonusSystem = await deploySystem(
      gameRootContract,
      'MiniGameBonusSystem'
    );

    //deploy Agent
    miniGameBonusSystemAgent = await deploySystem(
      gameRootContract,
      'MiniGameBonusSystemAgent'
    );

    storeU256SetSystem = await deploySystem(
      gameRootContract,
      'StoreU256SetSystem'
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
    it('success: should be able to bonus(winBonusExternal) with getSystemAddress', async function () {
      const [owner, addr1] = await ethers.getSigners();
      const amount = ethers.utils.parseEther('1');

      const miniGameBonusSystemId = ethers.utils.id(
        'game.systems.MiniGameBonusSystem'
      );

      const miniGameBonusAddress = await gameRootContract.getSystemAddress(
        miniGameBonusSystemId
      );
      const miniGameBonusSystemDynamic = await ethers.getContractAt(
        'MiniGameBonusSystem',
        miniGameBonusAddress
      );

      await miniGameBonusSystemDynamic.winBonusExternal(addr1.address, amount);
      const getBonus2 = await miniGameBonusSystemDynamic.bonusOf(addr1.address);
      expect(getBonus2).to.equal(amount);

      const getBonus = await miniGameBonusSystem.bonusOf(addr1.address);
      expect(getBonus).to.equal(amount);

      //   bytes32 constant _tableId = bytes32(
      //     keccak256(abi.encodePacked("tableId", "MiniGameBonusTable"))
      // );

      const _tableId = ethers.utils.id(`tableId` + `MiniGameBonusTable`);

      // get Bonus from getField
      //function getField(
      //     bytes32 tableId,
      //     bytes32[] memory key,
      //     uint8 schemaIndex
      // ) public view returns (bytes memory) {
      //     return _getField(tableId, key, schemaIndex);
      // }

      const bonus = await gameRootContract
        .getField(_tableId, [ethers.utils.hexZeroPad(addr1.address, 32)], 0)
        .then((res: any) => {
          return ethers.utils.defaultAbiCoder.decode(['uint256'], res)[0];
        });

      expect(bonus).to.equal(amount);
    });
  });

  describe('BonusAddressList', function () {
    it('success: should be able to addBonusAddressList', async function () {
      const [owner, addr1, addr2, addr3, addr4] = await ethers.getSigners();
      const amount = ethers.utils.parseEther('1');

      await miniGameBonusSystem.addBonusAddressList(addr1.address);

      await miniGameBonusSystem.getBonusAddressList().then((res: any) => {
        expect(res[0]).to.equal(addr1.address);
      });

      //test add 4 different address
      await miniGameBonusSystem.addBonusAddressList(addr1.address);
      await miniGameBonusSystem.addBonusAddressList(addr2.address);
      await miniGameBonusSystem.addBonusAddressList(addr3.address);
      await miniGameBonusSystem.addBonusAddressList(addr4.address);

      await miniGameBonusSystem.getBonusAddressList().then((res: any) => {
        expect(res[0]).to.equal(addr1.address);
        expect(res[1]).to.equal(addr2.address);
        expect(res[2]).to.equal(addr3.address);
        expect(res[3]).to.equal(addr4.address);

        // console.log(res);
      });

      //test remove 1 address
      await miniGameBonusSystem.removeBonusAddressList(addr1.address);

      await miniGameBonusSystem.getBonusAddressList().then((res: any) => {
        expect(res.length).to.equal(3);
      });
    });

    it('fail: should not be able to addBonusAddressList use StoreU256SetSystem', async function () {
      await expect(
        storeU256SetSystem['add(bytes32[],uint256)'](
          [ethers.utils.hexZeroPad('0x01', 32)],
          1
        )
      ).to.be.revertedWith(
        'AccessControl: account 0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266 is missing role 0x7c36da28cc8d8517c2cb99d17e2a1aed66b5d8a36bf0b347bb1aebd692d0a3c7'
      );
    });
  });
});
