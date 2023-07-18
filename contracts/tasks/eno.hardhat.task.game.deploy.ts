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
  'game.deploy:game-systems-deploy:new-systems',
  'Deploys or upgrades the game-systems contracts'
)
  .addOptionalParam(
    'start',
    'The start index of the systems to deploy, from 1',
    1,
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
        : Math.min(start + count - 1, gameDeploy.systems.length);

    console.log(`Deploy from:${start} to:${end} ...`);

    const systems = gameDeploy.systems;
    // step 1. Deploy new register system
    for (let i = start; i <= end; i++) {
      const systemContractName = systems[i - 1];
      console.log(`Check ${i}/${systems.length}, ${systemContractName} ...`);
      await hre.run('deploy-systems-new-system', {
        gameRootAddress,
        systemContractName,
      });
      console.log(`Check ${i}/${systems.length}, ${systemContractName} done`);
      //sleep 1s
      await new Promise((resolve) => setTimeout(resolve, 1000));
    }
  });

task(
  'game.deploy:game-systems-deploy:upgrade',
  'Deploys or upgrades the game-systems contracts'
)
  .addOptionalParam(
    'start',
    'The start index of the systems to deploy, from 1',
    1,
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
        : Math.min(start + count - 1, gameDeploy.systems.length);

    console.log(`Deploy from:${start} to:${end} ...`);

    const gameRootContractName = 'GameRoot';
    const gameRootContract = await hre.ethers.getContractAt(
      gameRootContractName,
      gameRootAddress as string
    );

    //pause game root before deploy
    process.stdout.write('Pause game root before deploy ... ');
    await gameRootContract.paused().then(async (paused: any) => {
      if (!paused) {
        await gameRootContract.pause();
      }
    });
    console.log('done!');

    const systems = gameDeploy.systems;
    // step 1. Deploy new register system
    for (let i = start; i <= end; i++) {
      const systemContractName = systems[i - 1];
      console.log(`Deploy ${i}/${systems.length}, ${systemContractName}`);
      await hre.run('deploy-systems-exist-system', {
        gameRootAddress,
        systemContractName,
      });

      console.log(`Deploy ${i}/${systems.length}, ${systemContractName} done`);
      //sleep 1s
      await new Promise((resolve) => setTimeout(resolve, 1000));
    }

    console.log(`Deploy ${start} to ${end} done`);

    //unpause game root after deploy
    process.stdout.write('Unpause game root after deploy ... ');
    await gameRootContract.paused().then(async (paused: any) => {
      if (paused) {
        await gameRootContract.unpause();
      }
    });
    console.log('done!');
  });
