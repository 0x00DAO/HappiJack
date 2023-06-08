import { expect } from 'chai';
import { BigNumber, Contract } from 'ethers';
import { ethers, upgrades } from 'hardhat';
import { gameDeploy } from '../../../scripts/consts/deploy.game.const';
import { eonTestUtil } from '../../../scripts/eno/eonTest.util';

describe('LotteryGameSellSystem', function () {
  let gameRootContract: Contract;
  let lotteryGameSystem: Contract;
  let lotteryGameSellSystem: Contract;

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

    lotteryGameSellSystem = await eonTestUtil.getSystem(
      gameRootContract,
      'LotteryGameSellSystem',
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

  describe.only('buyTicket', function () {
    it('success', async function () {
      // create a lottery game
      const lotteryGameId = await createLotteryGame();

      // buy ticket
      const [owner] = await ethers.getSigners();
      const ticketPrice = ethers.utils.parseEther('0.0005');
      const luckyNumber = 99988877;
      let ticketId = ethers.BigNumber.from(0);

      await expect(
        lotteryGameSellSystem.buyLotteryTicketETH(lotteryGameId, luckyNumber, {
          value: ticketPrice,
        })
      )
        .to.emit(lotteryGameSellSystem, 'LotteryTicketBuy')
        .withArgs(
          lotteryGameId,
          owner.address,
          (x: any) => {
            ticketId = x;
            return true;
          },
          luckyNumber
        );

      // check ticket
      const LotteryTicketTableId = ethers.utils.id(
        'tableId' + 'HappiJack' + 'LotteryTicketTable'
      );

      const ticketData = await gameRootContract
        .getRecord(
          LotteryTicketTableId,
          [ethers.utils.hexZeroPad(ticketId.toHexString(), 32)],
          5
        )
        .then((res: any) => {
          return {
            lotteryGameId: ethers.utils.defaultAbiCoder.decode(
              ['uint256'],
              res[0]
            )[0],
            Owner: ethers.utils.defaultAbiCoder.decode(['address'], res[1])[0],
            luckyNumber: ethers.utils.defaultAbiCoder.decode(
              ['uint256'],
              res[2]
            )[0],
            buyTime: ethers.utils.defaultAbiCoder.decode(
              ['uint256'],
              res[3]
            )[0],
            winStatus: ethers.utils.defaultAbiCoder.decode(
              ['uint256'],
              res[4]
            )[0],
          };
        });

      expect(ticketData.lotteryGameId).to.equal(lotteryGameId);
      expect(ticketData.Owner).to.equal(owner.address);
      expect(ticketData.luckyNumber).to.equal(luckyNumber);
      expect(ticketData.winStatus).to.equal(0);

      // check ticket sold amount

      // check bonus pool
    });
  });
});
