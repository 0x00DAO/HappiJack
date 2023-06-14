import { expect } from 'chai';
import { BigNumber, Contract } from 'ethers';
import { ethers, upgrades } from 'hardhat';
import { gameDeploy } from '../../../scripts/consts/deploy.game.const';
import { eonTestUtil } from '../../../scripts/eno/eonTest.util';
import { getTableRecord } from '../../../scripts/game/GameTableRecord';

describe('LotteryGameLotteryResultVerifySystem', function () {
  let gameRootContract: Contract;
  let lotteryGameSystem: Contract;
  let lotteryGameLotteryWalletSafeBoxSystem: Contract;

  beforeEach(async function () {
    //deploy GameRoot
    const GameRoot = await ethers.getContractFactory('GameRoot');
    gameRootContract = await upgrades.deployProxy(GameRoot, []);
    await gameRootContract.deployed();

    //deploy
    const systems = gameDeploy.systems;
    for (let i = 0; i < systems.length; i++) {
      await eonTestUtil.deploySystem(gameRootContract, systems[i]);
    }

    lotteryGameLotteryWalletSafeBoxSystem = await eonTestUtil.getSystem(
      gameRootContract,
      'LotteryGameLotteryWalletSafeBoxSystem',
      gameDeploy.systemIdPrefix
    );
  });

  async function createLotteryGame(): Promise<BigNumber> {
    const [owner] = await ethers.getSigners();

    const startTime = Math.floor(Date.now() / 1000); // current time
    const during = 60 * 60 * 24 * 1; // 1 days
    const endTime = startTime + during;

    const initialAmount = ethers.utils.parseEther('0.005');

    lotteryGameSystem = await eonTestUtil.getSystem(
      gameRootContract,
      'LotteryGameSystem',
      gameDeploy.systemIdPrefix
    );
    // const ownerFeeRate = 10;
    // create a lottery game
    let lotteryGameId = ethers.BigNumber.from(0);
    await expect(
      lotteryGameSystem.createLotteryGame(
        `It's a lottery game`,
        startTime,
        during,
        {
          value: initialAmount,
        }
      )
    )
      .to.emit(lotteryGameSystem, 'LotteryGameCreated')
      .withArgs(
        (x: any) => {
          lotteryGameId = x;
          return true;
        },
        owner.address,
        startTime,
        endTime
      );

    return lotteryGameId;
  }

  describe.only('depositETH', function () {
    const ticketPrice = ethers.utils.parseEther('0.0005');
    let lotteryGameId: BigNumber;
    let snapshotId: string;
    beforeEach(async function () {
      snapshotId = await ethers.provider.send('evm_snapshot', []);
      // create a lottery game
      // lotteryGameId = await createLotteryGame();
      // create block snapshot
      //register owner as system, so that owner can call system functions
      const [owner] = await ethers.getSigners();
      await gameRootContract.registerSystem(
        ethers.utils.id(owner.address),
        owner.address
      );
    });
    afterEach(async function () {
      // revert block
      await ethers.provider.send('evm_revert', [snapshotId]);
    });

    it('success: deposit', async function () {
      const [owner, addr1] = await ethers.getSigners();
      const initialAmount = ethers.utils.parseEther('0.005');
      // depositETH
      await expect(
        lotteryGameLotteryWalletSafeBoxSystem.depositETH(addr1.address, {
          value: initialAmount,
        })
      )
        .to.emit(lotteryGameLotteryWalletSafeBoxSystem, 'DepositETH')
        .withArgs(addr1.address, initialAmount);

      await getTableRecord
        .LotteryGameWalletSafeBoxTable(
          gameRootContract,
          addr1.address,
          BigNumber.from(0),
          ethers.constants.AddressZero
        )
        .then((x) => {
          expect(x.Amount).to.equal(initialAmount);
          return x;
        });

      //balanceOf eth
      await ethers.provider
        .getBalance(lotteryGameLotteryWalletSafeBoxSystem.address)
        .then((x) => {
          expect(x).to.equal(initialAmount);
          return x;
        });

      //deposit again
      const depositAmount = ethers.utils.parseEther('0.001');
      await expect(
        lotteryGameLotteryWalletSafeBoxSystem.depositETH(addr1.address, {
          value: depositAmount,
        })
      )
        .to.emit(lotteryGameLotteryWalletSafeBoxSystem, 'DepositETH')
        .withArgs(addr1.address, depositAmount);

      await getTableRecord
        .LotteryGameWalletSafeBoxTable(
          gameRootContract,
          addr1.address,
          BigNumber.from(0),
          ethers.constants.AddressZero
        )
        .then((x) => {
          expect(x.Amount).to.equal(initialAmount.add(depositAmount));
          return x;
        });
      //balanceOf eth
      await ethers.provider
        .getBalance(lotteryGameLotteryWalletSafeBoxSystem.address)
        .then((x) => {
          expect(x).to.equal(initialAmount.add(depositAmount));
          return x;
        });
    });

    it('fail: deposit, amount is zero', async function () {
      const [owner, addr1] = await ethers.getSigners();
      const initialAmount = ethers.utils.parseEther('0.00');
      // depositETH
      await expect(
        lotteryGameLotteryWalletSafeBoxSystem.depositETH(addr1.address, {
          value: initialAmount,
        })
      ).to.be.revertedWith(
        'LotteryGameLotteryWalletSafeBoxSystem: depositETH: msg.value must be greater than 0'
      );
    });

    it('fail: deposit, address is zero', async function () {
      const [owner, addr1] = await ethers.getSigners();
      const initialAmount = ethers.utils.parseEther('0.005');
      // depositETH
      await expect(
        lotteryGameLotteryWalletSafeBoxSystem.depositETH(
          ethers.constants.AddressZero,
          {
            value: initialAmount,
          }
        )
      ).to.be.revertedWith(
        'LotteryGameLotteryWalletSafeBoxSystem: depositETH: owner_ must not be 0 address'
      );
    });
  });
});
