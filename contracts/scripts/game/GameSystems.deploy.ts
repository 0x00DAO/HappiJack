// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
// const hre = require("hardhat");
import { ContractDeployAddress } from '../consts/deploy.address.const';
import { gameDeploy } from '../consts/deploy.game.const';
import { deployUtil } from '../utils/deploy.util';

const DeployContractName = 'GameRoot';
const contractGameRootAddress = ContractDeployAddress.GameRoot;

async function main() {
  const systems = gameDeploy.systems;

  // const systemContractName = 'LotteryGameLuckyNumberSystem';

  for (let i = 0; i < systems.length; i++) {
    const systemContractName = systems[i];
    console.log(`Deploy ${i + 1}/${systems.length}, ${systemContractName}`);

    const systemId = gameDeploy.systemId(systemContractName);
    await deployUtil.gameSystemDeploy(
      'GameRoot',
      contractGameRootAddress as string,
      systemContractName,
      systemId
    );

    console.log(
      `Deploy ${i + 1}/${systems.length}, ${systemContractName} done`
    );
    //sleep3s
    await new Promise((resolve) => setTimeout(resolve, 2000));

    console.log(`Deploy next ${i + 1}/${systems.length}`);
  }
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
