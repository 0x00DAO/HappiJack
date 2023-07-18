import { task, types } from 'hardhat/config';
import { ContractDeployAddress } from '../scripts/consts/deploy.address.const';
import { gameDeploy } from '../scripts/consts/deploy.game.const';
task(
  'game.deploy:game-root',
  'Deploys or upgrades the game-root contract'
).setAction(async (taskArgs, hre) => {
  await hre.run('deploy-upgrade-proxy', {
    contractName: 'GameRoot',
    contractAddress: ContractDeployAddress()?.GameRoot,
  });
});

task(
  'game.deploy:game-systems-deploy-new-systems',
  'Deploys or upgrades the game-systems contracts'
)
  .addOptionalParam(
    'start',
    'The start index of the systems to deploy',
    0,
    types.int
  )
  .addOptionalParam(
    'count',
    'The count of the systems to deploy, 0 means all',
    0,
    types.int
  )
  .setAction(async (taskArgs, hre) => {
    const gameRootAddress = ContractDeployAddress()?.GameRoot;
    const { start, count } = taskArgs;
    const end =
      count == 0
        ? gameDeploy.systems.length
        : Math.min(start + count, gameDeploy.systems.length);
    const systems = gameDeploy.systems;
    // step 1. Deploy new register system
    for (let i = start; i < end; i++) {
      const systemContractName = systems[i];
      console.log(
        `Check ${i + 1}/${systems.length}, ${systemContractName} ...`
      );
      await hre.run('deploy-systems-new-system', {
        gameRootAddress,
        systemContractName,
      });
      console.log(
        `Check ${i + 1}/${systems.length}, ${systemContractName} done`
      );
      //sleep 1s
      await new Promise((resolve) => setTimeout(resolve, 1000));
    }
  });
