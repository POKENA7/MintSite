const hre = require("hardhat");

describe("MaidsMarketPlace contract", function () {
  let ownner;
  let bob;
  let nft;

  beforeEach(async function () {
    [owner, bob] = await hre.ethers.getSigners();

    const NFTContract = await hre.ethers.getContractFactory("SampleNFT");
    nft = await NFTContract.deploy("https://hogehoge.com/", bob.address);
    await nft.deployed();
  });

  describe("Basic Checks", function () {
    it("Mint", async function () {
      await nft.connect(bob).mint(bob.address, 1);
    });
  });
});
