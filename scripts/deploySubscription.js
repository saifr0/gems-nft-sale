const hre = require("hardhat");
const { run } = require("hardhat");
async function verify(address, constructorArguments) {
  console.log(
    `verify  ${address} with arguments ${constructorArguments.join(",")}`
  );
  await run("verify:verify", {
    address,
    constructorArguments,
  });
}
async function main() {
  const fundsWalletAddress = process.env.fundsWalletAddress;
  const signerAddress = process.env.signerAddress;
  const owner = process.env.owner;
  const gemsAddress = process.env.gemsAddress;
  const subscriptionFeeInit = process.env.subscriptionFeeInit;

  const Subscription = await hre.ethers.deployContract("Subscription", [
    fundsWalletAddress,
    signerAddress,
    owner,
    gemsAddress,
    subscriptionFeeInit,
  ]);

  console.log("Deploying Subscription...");
  await Subscription.waitForDeployment();
  console.log("Subscription deployed to:", Subscription.target);

  await new Promise((resolve) => setTimeout(resolve, 20000));
  verify(Subscription.target, [
    fundsWalletAddress,
    signerAddress,
    owner,
    gemsAddress,
    subscriptionFeeInit,
  ]);
}
main();
