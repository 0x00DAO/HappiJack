// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
// const hre = require("hardhat");
import { Contract } from 'ethers';
import { ContractDeployAddress } from '../consts/deploy.address.const';
import { deployUpgradeProxy, deployUpgradeUpdate } from '../utils/deploy.util';

const DeployContractName = 'AirVoyageGameViewSystem';
const contractAddress = ContractDeployAddress.AirVoyageGameViewSystem;

async function main() {
  if (contractAddress) {
    const contract = await deployUpgradeUpdate(
      DeployContractName,
      contractAddress
    );
    await afterDeploy(contract);
  } else {
    const contract = await deployUpgradeProxy(DeployContractName, [
      ContractDeployAddress.GameRoot,
    ]);
    await afterDeploy(contract);
  }
}

async function afterDeploy(contract: Contract) {}
// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
