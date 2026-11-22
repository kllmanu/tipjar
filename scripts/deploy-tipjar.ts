import hre from "hardhat";
import { writeFile } from "node:fs/promises";
import { upgrades } from "@openzeppelin/hardhat-upgrades";

const connection = await hre.network.create();
const { ethers } = connection;
const upgradesApi = await upgrades(hre, connection);
const factory = await ethers.getContractFactory("TipJarFactory");
const proxy = await upgradesApi.deployProxy(factory, []);
await proxy.waitForDeployment();

const address = await proxy.getAddress();
await writeFile(
  "frontend/config.js",
  `// Updated by the deployment script whenever the factory contract is redeployed.\nwindow.TIP_JAR_FACTORY_ADDRESS = "${address}";\n`,
);

console.log(`TipJarFactory deployed at ${address}`);
