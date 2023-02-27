import { expect } from "chai";
import { ethers, network } from "hardhat";

const DAILY_YIELD_FROM_ONE_TOKEN = ethers.utils.parseUnits("10", "ether");
const DAILY_YIELD_FROM_FIVE_TOKENS = ethers.utils.parseUnits("50", "ether");

describe.only("Rare skills challenges", function () {
  let nft: any;
  let nftFactory: any;
  let token: any;
  let tokenFactory: any;
  let staking: any;
  let stakingFactory: any;
  let owner: any;
  let account1: any;
  let account2: any;
  let NFTEnumerableContract: any;
  let NFTEnumerableFactory: any;
  let gameContract: any;
  let gameFactory: any;
  let contractToHack: any;
  let hacker: any;

  let contractToHack2: any;
  let hacker2: any;


  before(async () => {
    [owner, account1, account2] = await ethers.getSigners();

    nftFactory = await ethers.getContractFactory("NFT");
    tokenFactory = await ethers.getContractFactory("Token");
    stakingFactory = await ethers.getContractFactory("Staking");
    NFTEnumerableFactory = await ethers.getContractFactory("NFTEnumerable");
    gameFactory = await ethers.getContractFactory("GameContract");

    let contractToHackFactory = await ethers.getContractFactory("Overmint1");
    contractToHack = await contractToHackFactory.deploy();

    let hackerContract = await ethers.getContractFactory("Overmint1Hack");
    hacker = await hackerContract.deploy(contractToHack.address);

    let contractToHack2Factory = await ethers.getContractFactory("Overmint2");
    contractToHack2 = await contractToHack2Factory.deploy();

    let hacker2Contract = await ethers.getContractFactory("Overmint2Hack");
    hacker2 = await hacker2Contract.deploy(contractToHack2.address);
  });

  beforeEach(async () => {
    nft = await nftFactory.deploy();
    await nft.deployed();

    token = await tokenFactory.deploy();
    await token.deployed();

    staking = await stakingFactory.deploy(nft.address, token.address);
    await staking.deployed();

    await token.connect(owner).setStakingAddress(staking.address);

    NFTEnumerableContract = await NFTEnumerableFactory.deploy();
    await NFTEnumerableContract.deployed();

    gameContract = await gameFactory.deploy(NFTEnumerableContract.address);
    await gameContract.deployed();
  });


  // describe("Staking functions", async () => {
  //   beforeEach(async () => {
  //     await nft.connect(account1).claim();
  //   });

  //   it("should allow user to stake NFT", async () => {
  //     await nft.connect(account1).setApprovalForAll(staking.address, true);
  //     await staking.connect(account1).deposit([1, 2, 3, 4, 5]);
  //     expect(await nft.ownerOf(1)).to.equal(staking.address);
  //     expect(await nft.balanceOf(staking.address)).to.equal(5);
  //   });

  //   it("should allow user to withdraw NFT", async () => {
  //     await nft.connect(account1).setApprovalForAll(staking.address, true);
  //     await staking.connect(account1).deposit([1, 2, 3, 4, 5]);
  //     await staking.connect(account1).withdraw([1, 2, 3]);
  //     expect(await nft.ownerOf(1)).to.equal(account1.address);
  //   });

  //   it("should not allow user to withdraw nft of other person", async () => {
  //     await nft.connect(account1).setApprovalForAll(staking.address, true);
  //     await staking.connect(account1).deposit([1, 2, 3, 4, 5]);
  //     let tx = staking.connect(account2).withdraw([1, 2, 3]);
  //     await expect(tx).to.be.revertedWith("Not the owner OR Token not staked");
  //   })
  // });

  // describe("Token accumulation and claim functions", async () => {
  //   beforeEach(async () => {
  //     await nft.connect(account1).claim();
  //     await nft.connect(account1).setApprovalForAll(staking.address, true);
  //     await staking.connect(account1).deposit([1]);
  //     await network.provider.send("evm_increaseTime", [86400]);
  //     await network.provider.send("evm_mine");
  //   });

  //   it("Should accumulate reward for a user", async () => {
  //     const accumuated = await staking.connect(account1).getAccumulatedAmount(account1.address);
  //     expect(accumuated).to.equal(DAILY_YIELD_FROM_ONE_TOKEN);
  //   });

  //   it("Should allow user to claim reward", async () => {
  //     await staking.connect(account1).claim();
  //     expect(await token.balanceOf(account1.address)).to.approximately(DAILY_YIELD_FROM_ONE_TOKEN, ethers.utils.parseUnits("0.00015", "ether"));
  //   });

  //   it("Should accumulate reward from 0 after user claimed reward", async () => {
  //     await staking.connect(account1).claim();
  //     const accumuated = await staking.connect(account1).getAccumulatedAmount(account1.address);
  //     expect(accumuated).to.equal(0);
  //   });

  //   it("Should accumulate 5x reward from 5 tokens", async () => {
  //     await staking.connect(account1).claim();
  //     await staking.connect(account1).deposit([2, 3, 4, 5]);
  //     await network.provider.send("evm_increaseTime", [86400]);
  //     await network.provider.send("evm_mine");
  //     const accumuated = await staking.connect(account1).getAccumulatedAmount(account1.address);
  //     expect(accumuated).to.equal(DAILY_YIELD_FROM_FIVE_TOKENS);
  //   });
  // });

  // describe("ERC721 enumerable", async () => {
  //   it("Should return prime numbers if a holder NFT ids", async () => {
  //     const primeNumbers = await gameContract.getUserPrimeNfts(owner.address);
  //     expect(primeNumbers).to.deep.equal([2, 3, 5, 7, 11, 13, 17, 19]);
  //   });
  // });

  describe("Overmint Hack 1", async () => {
    it("Should hack overmint contract", async () => {
      await hacker.hackMint();
      const balance = await contractToHack.balanceOf(hacker.address);
      expect(balance).to.equal(5);

      const success = await contractToHack.success(hacker.address);
      expect(success).to.equal(true);
    });
  });

  describe("Overmint Hack 2", async () => {
    it("Should hack overmint contract", async () => {
      await hacker.hackMint();
      const balance = await contractToHack.balanceOf(owner.address);
      expect(balance).to.equal(5);

      const success = await contractToHack.success(hacker.address);
      expect(success).to.equal(true);
    });
  });
});
