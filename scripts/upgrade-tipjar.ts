import hre from "hardhat";
import { readFile } from "node:fs/promises";
import { upgrades } from "@openzeppelin/hardhat-upgrades";

const connection = await hre.network.create();
const { ethers } = connection;
const upgradesApi = await upgrades(hre, connection);

const config = await readFile("frontend/config.js", "utf8");
const match = config.match(/TIP_JAR_FACTORY_ADDRESS\s*=\s*"([^"]+)"/);
if (!match?.[1]) {
  throw new Error("No proxy address found in frontend/config.js. Deploy first.");
}

const proxyAddress = match[1];
const factory = await ethers.getContractFactory("TipJarFactory");
await upgradesApi.upgradeProxy(proxyAddress, factory);

console.log(`TipJarFactory upgraded at proxy ${proxyAddress}`);
