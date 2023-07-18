import { subtask, task } from 'hardhat/config';
import { deployUpgradeProxy } from '../scripts/utils/deploy.util';
task(
  'game.deploy:game-root',
  'Deploys or upgrades the game-root contract'
).setAction(async (taskArgs, hre) => {
  const contractNames = await hre.artifacts.getAllFullyQualifiedNames();
  for (const contractFullName of contractNames) {
    console.log(contractFullName);
    const [contractSource, contractName] = contractFullName.split(':');
    console.log(contractName);

    const buildInfo = await hre.artifacts
      .getBuildInfo(contractFullName)
      .catch((e) => {
        // console.log(e);
      });
    if (!buildInfo) continue;
    console.log(buildInfo.output.contracts[contractSource][contractName]);
    // const { abi, devdoc, userdoc } = buildInfo.output.contracts[source][name];
  }
});

subtask('deploy-upgrade-proxy', 'Deploys or upgrades a proxy contract')
  .addParam('contractName', 'The name of the contract to deploy or upgrade')
  .addOptionalParam('contractAddress', 'The address of the contract to upgrade')
  .setAction(async (taskArgs, hre) => {
    const { contractName, contractAddress } = taskArgs;
    if (!contractAddress) {
      const contract = await deployUpgradeProxy(contractName);
    } else {
      // const contract = await deployUpgradeUpdate(contractName, contractAddress);
    }
  });
