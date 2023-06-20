// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
// const hre = require("hardhat");
import { ethers } from 'hardhat';
import { ContractDeployAddress } from '../consts/deploy.address.const';
import { gameDeploy } from '../consts/deploy.game.const';
import { deployUtil } from '../utils/deploy.util';

const DeployContractName = 'GameRoot';
const contractGameRootAddress = ContractDeployAddress.GameRoot;

async function main() {
  const systems = gameDeploy.systems;

  const GameRootContractName = 'GameRoot';
  const GameRootContractAddress = contractGameRootAddress;
  const gameRootContract = await ethers.getContractAt(
    GameRootContractName,
    GameRootContractAddress as string
  );
  // const systemContractName = 'LotteryGameLuckyNumberSystem';
  const deployedNewSystem: string[] = [];
  // step 1. Deploy new register system
  for (let i = 0; i < systems.length; i++) {
    const systemContractName = systems[i];
    console.log(`Check ${i + 1}/${systems.length}, ${systemContractName} ...`);

    const systemId = gameDeploy.systemId(systemContractName);
    const systemAddress = await deployUtil.gameSystemAddress(
      gameRootContract,
      systemId
    );
    if (systemAddress == ethers.constants.AddressZero) {
      console.log(`Deploy ${i + 1}/${systems.length}, ${systemContractName}`);
      deployedNewSystem.push(systemContractName);
      await deployUtil.gameSystemDeploy(
        GameRootContractName,
        contractGameRootAddress as string,
        systemContractName,
        systemId,
        undefined,
        undefined,
        false
      );
      console.log(
        `Deploy ${i + 1}/${systems.length}, ${systemContractName} done`
      );
    } else {
      console.log(
        `Deploy ${i + 1}/${systems.length}, ${systemContractName} exist`
      );
    }

    //sleep 1s
    await new Promise((resolve) => setTimeout(resolve, 1000));

    // console.log(`Deploy next ${i + 1}/${systems.length}`);
  }
  console.log('Deploy new system done', deployedNewSystem);
  // step 2. Deploy exist register system

  for (let i = 0; i < systems.length; i++) {
    const systemContractName = systems[i];
    console.log(`Deploy ${i + 1}/${systems.length}, ${systemContractName}`);

    if (!deployedNewSystem.includes(systemContractName)) {
      const systemId = gameDeploy.systemId(systemContractName);
      await deployUtil.gameSystemDeploy(
        GameRootContractName,
        contractGameRootAddress as string,
        systemContractName,
        systemId,
        undefined,
        undefined,
        false
      );

      console.log(
        `Deploy ${i + 1}/${systems.length}, ${systemContractName} done`
      );
    } else {
      console.log(
        `Deploy ${i + 1}/${
          systems.length
        }, ${systemContractName} skip, already deployed`
      );
    }
    //sleep 1s
    await new Promise((resolve) => setTimeout(resolve, 1000));
  }
  console.log('Deploy exist system done');
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
