import "dotenv/config";
import hardhatToolboxMochaEthersPlugin from "@nomicfoundation/hardhat-toolbox-mocha-ethers";
import hardhatUpgrades from "@openzeppelin/hardhat-upgrades";
import hardhatVerify from "@nomicfoundation/hardhat-verify";
import { defineConfig } from "hardhat/config";

const sepoliaRpcUrl =
  process.env.SEPOLIA_RPC_URL ??
  (process.env.INFURA_API_KEY
    ? `https://sepolia.infura.io/v3/${process.env.INFURA_API_KEY}`
    : "");
const sepoliaPrivateKey =
  process.env.SEPOLIA_PRIVATE_KEY ?? process.env.PRIVATE_KEY;

export default defineConfig({
  plugins: [hardhatToolboxMochaEthersPlugin, hardhatUpgrades, hardhatVerify],
  verify: {
    etherscan: {
      apiKey: process.env.ETHERSCAN_API_KEY ?? "",
    },
  },
  solidity: {
    profiles: {
      default: {
        version: "0.8.34",
      },
      production: {
        version: "0.8.34",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    },
  },
  networks: {
    localhost: {
      type: "http",
      chainType: "l1",
      url: "http://127.0.0.1:8545",
    },
    hardhatMainnet: {
      type: "edr-simulated",
      chainType: "l1",
    },
    hardhatOp: {
      type: "edr-simulated",
      chainType: "op",
    },
    sepolia: {
      type: "http",
      chainType: "l1",
      url: sepoliaRpcUrl,
      accounts: sepoliaPrivateKey ? [sepoliaPrivateKey] : [],
    },
  },
});
