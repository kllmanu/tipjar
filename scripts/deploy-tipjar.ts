import { writeFile } from "node:fs/promises";
import { network } from "hardhat";

const { ethers } = await network.create();
const factory = await ethers.deployContract("TipJarFactory");
await factory.waitForDeployment();

const address = await factory.getAddress();
await writeFile(
  "frontend/config.js",
  `// Updated by the deployment script whenever the factory contract is redeployed.\nwindow.TIP_JAR_FACTORY_ADDRESS = "${address}";\n`,
);

console.log(`TipJarFactory deployed at ${address}`);
