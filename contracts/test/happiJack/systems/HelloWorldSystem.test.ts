import { expect } from 'chai';
import { Contract } from 'ethers';
import { ethers, upgrades } from 'hardhat';
import { eonTestUtil } from '../../../scripts/eno/eonTest.util';

describe('HelloWorldSystem', function () {
  let gameRootContract: Contract;
  let helloWorldSystem: Contract;

  beforeEach(async function () {
    //deploy GameRoot
    const GameRoot = await ethers.getContractFactory('GameRoot');
    gameRootContract = await upgrades.deployProxy(GameRoot, []);
    await gameRootContract.deployed();

    //deploy HelloWorldSystem
    helloWorldSystem = await eonTestUtil.deploySystem(
      gameRootContract,
      'HelloWorldSystem'
    );
  });
  it('should be deployed', async function () {
    expect(helloWorldSystem.address).to.not.equal(null);
  });
  it('should return hello world', async function () {
    const helloWorld = await helloWorldSystem.sayHelloWord();
    expect(helloWorld).to.equal('Hello World!');
  });
});
