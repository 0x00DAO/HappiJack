import { subtask, task } from 'hardhat/config';
import { ContractDeployAddress } from '../scripts/consts/deploy.address.const';
import {
  deployUpgradeProxy,
  deployUpgradeUpdate,
} from '../scripts/utils/deploy.util';
task(
  'game.deploy:game-root',
  'Deploys or upgrades the game-root contract'
).setAction(async (taskArgs, hre) => {
  await hre.run('deploy-upgrade-proxy', {
    contractName: 'GameRoot',
    contractAddress: ContractDeployAddress()?.GameRoot,
  });
});

subtask('deploy-upgrade-proxy', 'Deploys or upgrades a proxy contract')
  .addParam('contractName', 'The name of the contract to deploy or upgrade')
  .addOptionalParam('contractAddress', 'The address of the contract to upgrade')
  .setAction(async (taskArgs, hre) => {
    const { contractName, contractAddress } = taskArgs;
    if (!contractAddress) {
      const contract = await deployUpgradeProxy(contractName);
    } else {
      const contract = await deployUpgradeUpdate(contractName, contractAddress);
    }
  });
