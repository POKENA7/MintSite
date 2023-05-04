const hre = require("hardhat");

async function main() {
  // SampleNFT.sol
  const SampleNFT = await hre.ethers.getContractFactory("SampleNFT");
  const sampleNFT = await SampleNFT.deploy(
    "https://gateway.pinata.cloud/ipfs/QmbxS6e3Znq7FBEezzunXTM36C2WLurCQG151ZGFFGpQ81/",
    "0x23CA0c2219de2C5A6bf13B66897303c2766f3DE5"
  );
  await sampleNFT.deployed();
  console.log(`SampleNFT: ${sampleNFT.address}`);

  // SampleSale.sol
  const SampleSale = await hre.ethers.getContractFactory("SampleSale");
  const sampleSale = await SampleSale.deploy(sampleNFT.address);
  await sampleSale.deployed();
  console.log(`SampleSale: ${sampleSale.address}`);

  sampleSale.setMerkleRoot(
    "0xd141dbfcff28a10896b39ba519bf0a21c65fa7e878bc5e057fa57d9e2665d5f0"
  );

  sampleNFT.setMinter(sampleSale.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
