import { expect } from 'chai';
import { Contract } from 'ethers';
import { ethers, upgrades } from 'hardhat';
import { eonTestUtil } from '../../../scripts/utils/eonTest.util';

describe('LotteryGameSystem', function () {
  let gameRootContract: Contract;
  let lotteryGameSystem: Contract;

  beforeEach(async function () {
    //deploy GameRoot
    const GameRoot = await ethers.getContractFactory('GameRoot');
    gameRootContract = await upgrades.deployProxy(GameRoot, []);
    await gameRootContract.deployed();

    //deploy
    lotteryGameSystem = await eonTestUtil.deploySystem(
      gameRootContract,
      'LotteryGameSystem'
    );
  });
  it('should be deployed', async function () {
    expect(lotteryGameSystem.address).to.not.equal(null);
  });

  describe('createLotteryGame', function () {
    it('success', async function () {
      const [owner] = await ethers.getSigners();

      const startTime = Math.floor(Date.now() / 1000); // current time
      const during = 60 * 60 * 24 * 1; // 1 days
      // create a lottery game
      await expect(
        lotteryGameSystem.createLotteryGame(
          `It's a lottery game`,
          startTime,
          during
        )
      )
        .to.emit(lotteryGameSystem, 'LotteryGameCreated')
        .withArgs(0, owner.address, startTime, startTime + during);

      // get lottery game

      const LotteryGameTableId = ethers.utils.id(
        'tableId' + 'HappiJack' + 'LotteryGameTable'
      );

      const lotteryGameData = await lotteryGameSystem.getLotteryGame(0);
      // console.log('lotteryGame', lotteryGameData);
      // console.log('owner', owner.address);
      expect(lotteryGameData.owner).to.equal(owner.address);

      // get lottery game from getRecord
      const lotteryGameDataFromGetRecord = await gameRootContract
        .getRecord(
          LotteryGameTableId,
          [ethers.utils.hexZeroPad(ethers.BigNumber.from(0).toHexString(), 32)],
          4
        )
        .then((res: any) => {
          return {
            owner: ethers.utils.defaultAbiCoder.decode(['address'], res[0])[0],
            ad: ethers.utils.toUtf8String(res[1]),
            startTime: ethers.utils.defaultAbiCoder.decode(
              ['uint256'],
              res[2]
            )[0],
            endTime: ethers.utils.defaultAbiCoder.decode(
              ['uint256'],
              res[3]
            )[0],
          };
        });

      expect(lotteryGameDataFromGetRecord.owner).to.equal(owner.address);
    });
  });
});
