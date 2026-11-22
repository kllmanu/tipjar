import { expect } from "chai";
import { network } from "hardhat";

const { ethers } = await network.create();

describe("SplitTipJar", function () {
  it("splits a tip and records it", async function () {
    const [owner, recipient, tipper] = await ethers.getSigners();
    const jar = await ethers.deployContract("SplitTipJar", [
      recipient.address,
      2000,
    ]);
    const amount = ethers.parseEther("1");

    await expect(jar.connect(tipper).tip("Thanks!", { value: amount }))
      .to.emit(jar, "TipReceived")
      .withArgs(tipper.address, amount, ethers.parseEther("0.2"), "Thanks!");

    expect(await jar.getTipsCount()).to.equal(1n);

    const savedTip = await jar.getTip(0);
    expect(savedTip.sender).to.equal(tipper.address);
    expect(savedTip.amount).to.equal(amount);
    expect(savedTip.message).to.equal("Thanks!");

    expect(await ethers.provider.getBalance(recipient.address))
      .to.equal(ethers.parseEther("10000.2"));
  });

  it("rejects invalid split percentages", async function () {
    const [, recipient] = await ethers.getSigners();

    await expect(
      ethers.deployContract("SplitTipJar", [recipient.address, 10001]),
    ).to.be.revertedWithCustomError(
      await ethers.getContractFactory("SplitTipJar"),
      "InvalidSplit",
    );
  });

  it("rejects zero-value tips", async function () {
    const [, recipient] = await ethers.getSigners();
    const jar = await ethers.deployContract("SplitTipJar", [
      recipient.address,
      2000,
    ]);

    await expect(jar.tip("")).to.be.revertedWithCustomError(jar, "ZeroTip");
  });
});
