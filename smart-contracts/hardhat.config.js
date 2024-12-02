require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

const ALCHEMY_SEPOLIA_RPC = process.env.ALCHEMY_SEPOLIA_RPC;
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY;

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.27",
  networks: {
    hardhat: {},
    // sepolia: {
    //   url: ALCHEMY_SEPOLIA_RPC,
    //   accounts: [PRIVATE_KEY],
    //   chainId: 11155111,
    //   allowUnlimitedContractSize: true,
    // },
  },
  settings: {
    optimizer: {
      enabled: true,
      runs: 200,
      details: { yul: false },
    },
  },
  // etherscan: {
  //   apiKey: ETHERSCAN_API_KEY,
  // },
  // sourcify: {
  //   enabled: true,
  // },
};
