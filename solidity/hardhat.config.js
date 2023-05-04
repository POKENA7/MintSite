require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");
require("@typechain/hardhat");
require("@nomiclabs/hardhat-ethers");
require("hardhat-gas-reporter");
require("dotenv").config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: "0.8.13",
    settings: {
      optimizer: {
        enabled: true,
        runs: 300,
      },
    },
  },
  networks: {
    mainnet: {
      url: process.env.MAINNET_RPC_URL,
      accounts: [`${process.env.PRIVATE_KEY}`],
    },
    sepolia: {
      url: process.env.SEPOLIA_RPC_URL,
      accounts: [`${process.env.PRIVATE_KEY}`],
    },
    goerli: {
      url: process.env.GOERLI_RPC_URL,
      accounts: [`${process.env.PRIVATE_KEY}`],
      // gasPrice: 50000000000, // 50 gwei
    },
    polygon: {
      url: process.env.POLYGON_RPC_URL,
      accounts: [`${process.env.PRIVATE_KEY}`],
    },
  },
  etherscan: {
    apiKey: {
      sepolia: process.env.ETHERSCAN_KEY,
      polygon: process.env.POLYGONSCAN_KEY,
    },
  },
  gasReporter: {
    gasPrice: 62,
    enabled: true,
    currency: "JPY",
    gasPriceApi:
      "https://api.etherscan.io/api?module=proxy&action=eth_gasPrice",
    coinmarketcap: process.env.COINMARKETCAP_KEY,
  },
  typechain: {
    outDir: "typechain",
    target: "ethers-v5",
  },
};
