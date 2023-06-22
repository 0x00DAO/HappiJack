import { task } from 'hardhat/config';
task(
  'game.deploy:game-root',
  'Deploys or upgrades the game-root contract'
).setAction(async (taskArgs, hre) => {
  console.log('game.deploy:game-root');
});
