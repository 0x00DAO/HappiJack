import { task } from 'hardhat/config';
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
