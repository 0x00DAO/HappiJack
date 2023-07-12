import { expect } from 'chai';
import { Contract } from 'ethers';
import { ethers, upgrades } from 'hardhat';
import { deployUtil } from '../../../../scripts/utils/deploy.util';

describe('MiniGameBonusSystemBonusAddressList', function () {
  let gameRootContract: Contract;
  let miniGameBonusSystem: Contract;
  let miniGameBonusSystemAgent: Contract;
  let storeU256SetSystem: Contract;

  async function deploySystem(
    gameRoot: Contract,
    contractName: string
  ): Promise<Contract> {
    //deploy Agent
    const SystemContract = await ethers.getContractFactory(contractName);
    const systemContract = await upgrades.deployProxy(SystemContract, [
      gameRoot.address,
    ]);
    //register system
    await deployUtil.gameRegisterSystem(gameRoot, systemContract.address);
    return systemContract;
  }

  beforeEach(async function () {
    //deploy GameRoot
    const GameRoot = await ethers.getContractFactory('GameRoot');
    gameRootContract = await upgrades.deployProxy(GameRoot, []);
    await gameRootContract.deployed();

    //deploy MiniGameBonusSystem
    miniGameBonusSystem = await deploySystem(
      gameRootContract,
      'MiniGameBonusSystem'
    );

    //deploy Agent
    miniGameBonusSystemAgent = await deploySystem(
      gameRootContract,
      'MiniGameBonusSystemAgent'
    );

    storeU256SetSystem = await deploySystem(
      gameRootContract,
      'StoreU256SetSystem'
    );
  });

  describe('BonusAddressList', function () {
    it('success: should be able to addBonusAddressList', async function () {
      const [owner, addr1, addr2, addr3, addr4] = await ethers.getSigners();
      const amount = ethers.utils.parseEther('1');

      await miniGameBonusSystem.addBonusAddressList(addr1.address);

      await miniGameBonusSystem.getBonusAddressList().then((res: any) => {
        expect(res[0]).to.equal(addr1.address);
      });

      //test add 4 different address
      await miniGameBonusSystem.addBonusAddressList(addr1.address);
      await miniGameBonusSystem.addBonusAddressList(addr2.address);
      await miniGameBonusSystem.addBonusAddressList(addr3.address);
      await miniGameBonusSystem.addBonusAddressList(addr4.address);

      await miniGameBonusSystem.getBonusAddressList().then((res: any) => {
        expect(res[0]).to.equal(addr1.address);
        expect(res[1]).to.equal(addr2.address);
        expect(res[2]).to.equal(addr3.address);
        expect(res[3]).to.equal(addr4.address);

        // console.log(res);
      });

      //test remove 1 address
      await miniGameBonusSystem.removeBonusAddressList(addr1.address);

      await miniGameBonusSystem.getBonusAddressList().then((res: any) => {
        expect(res.length).to.equal(3);
      });
    });

    it('success: should be able to addBonusAddressList use storeU256SetSystem', async function () {
      const [owner, addr1, addr2, addr3, addr4] = await ethers.getSigners();
      //test add 4 different address
      await miniGameBonusSystem.addBonusAddressList(addr1.address);
      await miniGameBonusSystem.addBonusAddressList(addr2.address);
      await miniGameBonusSystem.addBonusAddressList(addr3.address);
      await miniGameBonusSystem.addBonusAddressList(addr4.address);

      const tableId = ethers.utils.id('tableId' + 'MiniGameBonusListTable');
      const Key = ethers.utils.id(
        'game.systems.MiniGameBonusSystem.ID_BonusAddressList'
      );
      const query = [tableId, Key];

      await storeU256SetSystem['values(bytes32[])'](query).then((res: any) => {
        expect(res[0]).to.equal(addr1.address);
        expect(res[1]).to.equal(addr2.address);
        expect(res[2]).to.equal(addr3.address);
        expect(res[3]).to.equal(addr4.address);
      });
    });
  });

  describe('StoreU256SetSystem', function () {
    it('fail: should not be able to addBonusAddressList use StoreU256SetSystem', async function () {
      await expect(
        storeU256SetSystem['add(bytes32[],uint256)'](
          [ethers.utils.hexZeroPad('0x01', 32)],
          1
        )
      ).to.be.revertedWith(
        'AccessControl: account 0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266 is missing role 0x7c36da28cc8d8517c2cb99d17e2a1aed66b5d8a36bf0b347bb1aebd692d0a3c7'
      );
    });

    describe('values', function () {
      it('success: values(bytes32[])', async function () {
        const [owner, addr1, addr2, addr3, addr4] = await ethers.getSigners();
        //test add 4 different address
        await miniGameBonusSystem.addBonusAddressList(addr1.address);
        await miniGameBonusSystem.addBonusAddressList(addr2.address);
        await miniGameBonusSystem.addBonusAddressList(addr3.address);
        await miniGameBonusSystem.addBonusAddressList(addr4.address);

        const tableId = ethers.utils.id('tableId' + 'MiniGameBonusListTable');
        const Key = ethers.utils.id(
          'game.systems.MiniGameBonusSystem.ID_BonusAddressList'
        );
        const query = [tableId, Key];

        await storeU256SetSystem['values(bytes32[])'](query).then(
          (res: any) => {
            expect(res[0]).to.equal(addr1.address);
            expect(res[1]).to.equal(addr2.address);
            expect(res[2]).to.equal(addr3.address);
            expect(res[3]).to.equal(addr4.address);
          }
        );
      });

      it('success: values(bytes32[][])', async function () {
        const [owner, addr1, addr2, addr3, addr4] = await ethers.getSigners();
        //test add 4 different address
        await miniGameBonusSystem.addBonusAddressList(addr1.address);
        await miniGameBonusSystem.addBonusAddressList(addr2.address);
        await miniGameBonusSystem.addBonusAddressList(addr3.address);
        await miniGameBonusSystem.addBonusAddressList(addr4.address);

        const tableId = ethers.utils.id('tableId' + 'MiniGameBonusListTable');
        const Key = ethers.utils.id(
          'game.systems.MiniGameBonusSystem.ID_BonusAddressList'
        );
        const query = [tableId, Key];

        await storeU256SetSystem['values(bytes32[][])']([query, query]).then(
          (res: any) => {
            expect(res[0][0]).to.equal(addr1.address);
            expect(res[0][1]).to.equal(addr2.address);
            expect(res[0][2]).to.equal(addr3.address);
            expect(res[0][3]).to.equal(addr4.address);

            expect(res[1][0]).to.equal(addr1.address);
            expect(res[1][1]).to.equal(addr2.address);
            expect(res[1][2]).to.equal(addr3.address);
            expect(res[1][3]).to.equal(addr4.address);
          }
        );
      });

      it('success: values(bytes32[],uint256,uint256)', async function () {
        const [owner, addr1, addr2, addr3, addr4] = await ethers.getSigners();
        //test add 4 different address
        await miniGameBonusSystem.addBonusAddressList(addr1.address);
        await miniGameBonusSystem.addBonusAddressList(addr2.address);
        await miniGameBonusSystem.addBonusAddressList(addr3.address);
        await miniGameBonusSystem.addBonusAddressList(addr4.address);

        const tableId = ethers.utils.id('tableId' + 'MiniGameBonusListTable');
        const Key = ethers.utils.id(
          'game.systems.MiniGameBonusSystem.ID_BonusAddressList'
        );
        const query = [tableId, Key];

        //test get 2 address
        await storeU256SetSystem['values(bytes32[],uint256,uint256)'](
          query,
          0,
          2
        ).then((res: any) => {
          expect(res[0]).to.equal(addr1.address);
          expect(res[1]).to.equal(addr2.address);
        });

        //test get 2 address
        await storeU256SetSystem['values(bytes32[],uint256,uint256)'](
          query,
          2,
          2
        ).then((res: any) => {
          expect(res[0]).to.equal(addr3.address);
          expect(res[1]).to.equal(addr4.address);
        });

        //test get 1 address
        await storeU256SetSystem['values(bytes32[],uint256,uint256)'](
          query,
          3,
          2
        ).then((res: any) => {
          expect(res[0]).to.equal(addr4.address);
        });

        //test get 0 address
        await storeU256SetSystem['values(bytes32[],uint256,uint256)'](
          query,
          4,
          2
        ).then((res: any) => {
          expect(res.length).to.equal(0);
        });

        //test get 4 address
        await storeU256SetSystem['values(bytes32[],uint256,uint256)'](
          query,
          0,
          4
        ).then((res: any) => {
          expect(res[0]).to.equal(addr1.address);
          expect(res[1]).to.equal(addr2.address);
          expect(res[2]).to.equal(addr3.address);
          expect(res[3]).to.equal(addr4.address);
        });

        //test get 5 address
        await storeU256SetSystem['values(bytes32[],uint256,uint256)'](
          query,
          0,
          5
        ).then((res: any) => {
          expect(res.length).to.equal(4);
          expect(res[0]).to.equal(addr1.address);
          expect(res[1]).to.equal(addr2.address);
          expect(res[2]).to.equal(addr3.address);
          expect(res[3]).to.equal(addr4.address);
        });
      });
    });
  });
});
