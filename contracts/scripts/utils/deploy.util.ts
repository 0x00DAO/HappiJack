import { DeployProxyOptions } from '@openzeppelin/hardhat-upgrades/dist/utils';
import { assert } from 'console';
import { Contract, ContractFactory, ContractTransaction } from 'ethers';
import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { getRuntimeConfig } from './config.util';

function getHre() {
  const hre = require('hardhat');
  return hre;
}

/**
 *
 * @param DeployContractName
 * @param deployContract
 * @returns Contract
 */
async function _deploy(
  DeployContractName: string,
  deployContract: Contract,
  hre: HardhatRuntimeEnvironment
): Promise<Contract> {
  // We get the contract to deploy
  console.log('[deploy contract]:deploy [%s] start', DeployContractName);
  const [deployer] = await hre.ethers.getSigners();
  console.log('[deploy contract]:deployer address', deployer.address);
  const deployerBalance = await deployer.getBalance();
  console.log(
    '[deploy contract]:deployer balance before',
    hre.ethers.utils.formatEther(deployerBalance)
  );
  await deployContract.deployed();

  const deployerBalanceAfter = await deployer.getBalance();
  console.log(
    '[deploy contract]:deployer balance after',
    hre.ethers.utils.formatEther(deployerBalanceAfter)
  );
  console.log(
    '[deploy contract]:deploy gas fee',
    hre.ethers.utils.formatEther(deployerBalance.sub(deployerBalanceAfter))
  );
  console.log(
    '[deploy contract]:deploy complete! contract: [%s] deployed to: %s',
    DeployContractName,
    deployContract.address
  );
  return deployContract;
}
/**
 * deploy contract(not upgradeable)
 * @param DeployContractName  contract name
 * @param args  contract args
 * @returns  Contract
 */
export async function deployNormal(
  DeployContractName: string,
  ...args: any[]
): Promise<Contract> {
  const hre = getHre();
  const DeployContract = await hre.ethers.getContractFactory(
    DeployContractName
  );
  const deployContract = await DeployContract.deploy(...args);
  return _deploy(DeployContractName, deployContract, hre);
}

/**
 * deploy upgradeable contract
 * @param contractName contract name
 * @returns contract address
 */
export async function deployUpgradeProxy(
  contractName: string,
  args?: unknown[],
  opts?: DeployProxyOptions
): Promise<Contract> {
  const hre = getHre();
  const DeployContractName = contractName;
  const DeployContract = await hre.ethers.getContractFactory(
    DeployContractName
  );
  const deployContract = await hre.upgrades.deployProxy(
    DeployContract,
    args,
    opts
  );
  return _deploy(DeployContractName, deployContract, hre);
}
/**
 * update upgradeable contract
 * @param contractName contract name
 * @param contractAddress  contract address
 * @returns
 */
export async function deployUpgradeUpdate(
  contractName: string,
  contractAddress: string,
  forceImport?: boolean
): Promise<Contract> {
  const hre = getHre();
  console.log('[deploy contract]:deploy [%s] upgrade ...', contractName);
  const DeployContractName = contractName;
  const DeployContract = await getContractFactory(DeployContractName);
  let deployContract;
  if (forceImport) {
    deployContract = await hre.upgrades.forceImport(
      contractAddress,
      DeployContract
    );
  } else {
    deployContract = await hre.upgrades.upgradeProxy(
      contractAddress,
      DeployContract
    );
  }
  return _deploy(DeployContractName, deployContract, hre);
}

/**
 * update upgradeable contract (through defender proposal)
 * @param contractName contract name
 * @param contractAddress  contract address
 * @returns
 */
export async function deployUpgradeUpdateWithProposal(
  contractName: string,
  contractAddress: string
): Promise<void> {
  const hre = getHre();
  console.log('[deploy contract]:deploy [%s] upgrade ...', contractName);
  const Contract = await getContractFactory(contractName);
  console.log('Preparing proposal...');
  const runtimeConfig = getRuntimeConfig();
  console.log(
    'Upgrade proposal with multisig at:',
    runtimeConfig.upgradeDefenderMultiSigAddress
  );
  const proposal = await hre.defender.proposeUpgrade(
    contractAddress,
    Contract,
    {
      multisig: runtimeConfig.upgradeDefenderMultiSigAddress,
    }
  );
  console.log('Upgrade proposal created at:', proposal.url);
}

export async function getContractFactory(
  contractName: string
): Promise<ContractFactory> {
  const hre = getHre();
  return hre.ethers.getContractFactory(contractName);
}

async function deployGrantRoles(
  contract: Contract,
  roles: {
    roleId: string;
    roleName: string;
  }[],
  grantAddress: string
) {
  for (const role of roles) {
    await contract
      .grantRole(role.roleId, grantAddress)
      .then((tx: ContractTransaction) => tx.wait());
    console.log(
      `contract: ${contract.address}, grant: '${role.roleName} role' to address: ${grantAddress}`
    );
  }
}

async function deployRevokeRoles(
  contract: Contract,
  roles: {
    roleId: string;
    roleName: string;
  }[],
  revokeAddress: string
) {
  for (const role of roles) {
    await contract
      .revokeRole(role.roleId, revokeAddress)
      .then((tx: ContractTransaction) => tx.wait());
    console.log(
      `contract: ${contract.address}, revoke: '${role.roleName} role' from address: ${revokeAddress}`
    );
  }
}

async function gameRegisterSystem(gameRoot: Contract, systemAddress: string) {
  await gameRoot
    .registerSystemWithAddress(systemAddress)
    .then((tx: ContractTransaction) => tx.wait());

  //grant system to write
  await gameEntityGrantWriteRole(gameRoot, [systemAddress]);
}

async function gameEntityGrantWriteRole(
  contract: Contract,
  grantAddress: string[]
) {
  const hre = getHre();
  const role = hre.ethers.utils.id('COMPONENT_WRITE_ROLE');
  for (const address of grantAddress) {
    //check if already grant
    const hasRole = await contract.hasRole(role, address);
    if (!hasRole) {
      await contract
        .grantRole(role, address)
        .then((tx: ContractTransaction) => tx.wait());
    }
  }
}
async function gameSystemGrantInternalRole(
  contract: Contract,
  grantAddress: string[]
) {
  const hre = getHre();
  const role = hre.ethers.utils.id('SYSTEM_INTERNAL_ROLE');
  for (const address of grantAddress) {
    await contract
      .grantRole(role, address)
      .then((tx: ContractTransaction) => tx.wait());

    console.log(
      `contract: ${contract.address}, grant: 'SYSTEM_INTERNAL_ROLE' to address: ${address}`
    );
  }
}

async function gameSystemAddress(
  gameRootContract: Contract,
  GameSystemId: string
): Promise<string> {
  const hre = getHre();
  const systemContractId = hre.ethers.utils.id(`${GameSystemId}`);
  const systemContractAddress = await gameRootContract.getSystemAddress(
    systemContractId
  );
  return systemContractAddress;
}

async function gameSystemDeploy(
  GameRootContractName = 'GameRoot',
  GameRootContractAddress: string,
  GameSystemContractName: string,
  GameSystemId: string,
  GameSystemContractArgs?: any[],
  opts?: DeployProxyOptions,
  forceImport?: boolean
): Promise<Contract> {
  assert(GameRootContractAddress, 'GameRoot contract address is not set');
  const hre = getHre();
  const gameRootContract = await hre.ethers.getContractAt(
    GameRootContractName,
    GameRootContractAddress
  );

  const systemContractAddress = await gameSystemAddress(
    gameRootContract,
    GameSystemId
  );

  console.log(
    `[deploy contract]:System Contract: ${GameSystemContractName}, address: ${systemContractAddress}`
  );

  let contract: Contract;
  if (systemContractAddress == hre.ethers.constants.AddressZero) {
    if (!GameSystemContractArgs) {
      GameSystemContractArgs = [];
    }
    contract = await deployUpgradeProxy(
      GameSystemContractName,
      [GameRootContractAddress, ...GameSystemContractArgs],
      opts
    );
    await gameRegisterSystem(gameRootContract, contract.address);
  } else {
    contract = await deployUpgradeUpdate(
      GameSystemContractName,
      systemContractAddress,
      forceImport
    );

    //grant system to write
    await gameEntityGrantWriteRole(gameRootContract, [systemContractAddress]);
  }

  return contract;
}

export const deployUtil = {
  grantRoles: deployGrantRoles,
  revokeRoles: deployRevokeRoles,
  gameEntityGrantWriteRole: gameEntityGrantWriteRole,
  gameSystemGrantInternalRole: gameSystemGrantInternalRole,
  gameRegisterSystem: gameRegisterSystem,
  gameSystemDeploy: gameSystemDeploy,
  gameSystemAddress: gameSystemAddress,
};
