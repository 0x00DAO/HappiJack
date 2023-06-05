import { Contract } from 'ethers';
import { ethers, upgrades } from 'hardhat';
import { deployUtil } from './deploy.util';

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

export const eonTestUtil = {
  deploySystem: deploySystem,
};
