import { expect } from 'chai';
import { Contract } from 'ethers';
import { ethers, upgrades } from 'hardhat';
import { deployUtil } from '../../../../scripts/utils/deploy.util';

describe('MiniGameBonusSystemGameRoot', function () {
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

  describe('IStoreRead', function () {
    it('success: getRecords', async function () {
      const [owner, addr1] = await ethers.getSigners();
      const amount = ethers.utils.parseEther('1');

      const miniGameBonusAddress = await gameRootContract.getSystemAddress(
        ethers.utils.id('game.systems.MiniGameBonusSystem')
      );

      const miniGameBonusSystemDynamic = await ethers.getContractAt(
        'MiniGameBonusSystem',
        miniGameBonusAddress
      );

      await miniGameBonusSystemDynamic.winBonusExternal(addr1.address, amount);

      const _tableId = ethers.utils.id(`tableId` + `MiniGameBonusTable`);
      const bonus = await gameRootContract
        .getField(_tableId, [ethers.utils.hexZeroPad(addr1.address, 32)], 0)
        .then((res: any) => {
          return ethers.utils.defaultAbiCoder.decode(['uint256'], res)[0];
        });

      expect(bonus).to.equal(amount);

      const recordIndices = [];
      recordIndices.push([
        _tableId,
        [ethers.utils.hexZeroPad(addr1.address, 32)],
        1,
      ]);
      recordIndices.push([
        _tableId,
        [ethers.utils.hexZeroPad(addr1.address, 32)],
        1,
      ]);

      await gameRootContract.getRecords(recordIndices).then((res: any) => {
        expect(res[0][0]).to.equal(amount);
        expect(res[1][0]).to.equal(amount);
      });
    });
  });
});
