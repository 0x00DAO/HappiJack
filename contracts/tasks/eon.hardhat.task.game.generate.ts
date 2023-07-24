import { task } from 'hardhat/config';
task(
  'game.generate:table-ids',
  'Generates a table id from a game id and a table number'
).setAction(async (taskArgs, hre) => {
  const contractNames = await hre.artifacts.getAllFullyQualifiedNames();
  for (const contractFullName of contractNames) {
    const [contractSource, contractName] = contractFullName.split(':');
    if (contractName !== 'LotteryGameTable') continue;
    console.log(contractFullName);
    console.log(contractName);

    const buildInfo = await hre.artifacts
      .getBuildInfo(contractFullName)
      .catch((e) => {
        // console.log(e);
      });
    if (!buildInfo) continue;
    const contractBuildInfo =
      buildInfo.output.contracts[contractSource][contractName];
    console.log(contractBuildInfo);

    const LotteryGameBonusPoolTableId =
      contractBuildInfo.evm.bytecode.object.slice(2);
    console.log(LotteryGameBonusPoolTableId);
    console.log(
      hre.ethers.utils.id('tableId' + 'HappiJack' + 'LotteryGameTable')
    );

    // const { abi, devdoc, userdoc } = buildInfo.output.contracts[source][name];
  }
});
