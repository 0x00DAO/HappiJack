import { task } from 'hardhat/config';
import { ContractDeployAddress } from '../scripts/consts/deploy.address.const';
import { gameDeploy } from '../scripts/consts/deploy.game.const';
task(
  'game.systems',
  'Prints the list of game-system',
  async (taskArgs, hre) => {
    const systems = gameDeploy.systems;

    const contractGameRootAddress = ContractDeployAddress.GameRoot;
    console.log(`GameRootContractAddress: ${contractGameRootAddress}`);

    for (const system of systems) {
      const systemId = hre.ethers.utils.id(gameDeploy.systemId(system));
      const systemIdAsNumber = hre.ethers.BigNumber.from(systemId);
      console.log(`${system}  =>  ${systemIdAsNumber}`);
    }
  }
);

task('game.system:ids', 'Prints the specified system id')
  .addParam('name', 'The system name')
  .setAction(async (taskArgs, hre) => {
    const system = taskArgs.name;
    const systemId = hre.ethers.utils.id(gameDeploy.systemId(system));
    const systemIdAsNumber = hre.ethers.BigNumber.from(systemId);
    console.log(`${system}  =>  ${systemIdAsNumber}`);
  });
