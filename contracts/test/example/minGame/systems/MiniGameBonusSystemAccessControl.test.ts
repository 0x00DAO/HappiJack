import { expect } from 'chai';
import { Contract } from 'ethers';
import { ethers, upgrades } from 'hardhat';
import { deployUtil } from '../../../../scripts/utils/deploy.util';

describe('MiniGameBonusSystemAccessControl', function () {
  let gameRootContract: Contract;
  let miniGameBonusSystem: Contract;
  let miniGameBonusSystemAgent: Contract;
  let storeU256SetSystem: Contract;

  const DEFAULT_ADMIN_ROLE: string = ethers.utils.hexZeroPad('0x00', 32);
  const PAUSER_ROLE: string = ethers.utils.id('PAUSER_ROLE');
  const UPGRADER_ROLE: string = ethers.utils.id('UPGRADER_ROLE');

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

  describe('Access Control', function () {
    it('success: has role owner', async function () {
      const [owner, addr1] = await ethers.getSigners();

      expect(
        await miniGameBonusSystem.hasRole(DEFAULT_ADMIN_ROLE, owner.address)
      ).to.equal(true);

      expect(
        await miniGameBonusSystem.hasRole(DEFAULT_ADMIN_ROLE, addr1.address)
      ).to.equal(false);

      expect(
        await miniGameBonusSystem.hasRole(PAUSER_ROLE, owner.address)
      ).to.equal(true);

      expect(
        await miniGameBonusSystem.hasRole(PAUSER_ROLE, addr1.address)
      ).to.equal(false);
    });

    it('success: revoke role from system not effect', async function () {
      const [owner, addr1] = await ethers.getSigners();
      expect(
        await miniGameBonusSystem.hasRole(PAUSER_ROLE, owner.address)
      ).to.equal(true);
      //revoking role from system not effect
      await miniGameBonusSystem.revokeRole(PAUSER_ROLE, owner.address);
      expect(
        await miniGameBonusSystem.hasRole(PAUSER_ROLE, owner.address)
      ).to.equal(true);

      //revoking role from root has effect
      await gameRootContract.revokeRole(PAUSER_ROLE, owner.address);
      expect(
        await miniGameBonusSystem.hasRole(PAUSER_ROLE, owner.address)
      ).to.equal(false);
    });

    it('success: grant local role to system has effect', async function () {
      const [owner, addr1] = await ethers.getSigners();
      expect(
        await miniGameBonusSystem.hasRole(PAUSER_ROLE, addr1.address)
      ).to.equal(false);
      //granting local role to system has effect
      await miniGameBonusSystem.grantRole(PAUSER_ROLE, addr1.address);
      expect(
        await miniGameBonusSystem.hasRole(PAUSER_ROLE, addr1.address)
      ).to.equal(true);

      //revoking role from root not effect
      await gameRootContract.revokeRole(PAUSER_ROLE, addr1.address);
      expect(
        await miniGameBonusSystem.hasRole(PAUSER_ROLE, addr1.address)
      ).to.equal(true);

      //revoking role from system has effect
      await miniGameBonusSystem.revokeRole(PAUSER_ROLE, addr1.address);
      expect(
        await miniGameBonusSystem.hasRole(PAUSER_ROLE, addr1.address)
      ).to.equal(false);
    });

    it('success: grant role to root has effect', async function () {
      const [owner, addr1] = await ethers.getSigners();
      expect(
        await miniGameBonusSystem.hasRole(PAUSER_ROLE, addr1.address)
      ).to.equal(false);
      //granting role to root has effect
      await gameRootContract.grantRole(PAUSER_ROLE, addr1.address);
      expect(
        await miniGameBonusSystem.hasRole(PAUSER_ROLE, addr1.address)
      ).to.equal(true);

      //revoking role from root has effect
      await gameRootContract.revokeRole(PAUSER_ROLE, addr1.address);
      expect(
        await miniGameBonusSystem.hasRole(PAUSER_ROLE, addr1.address)
      ).to.equal(false);
    });
  });
});
