const hre = require('hardhat');
const { run } = require('hardhat');
async function verify(address, constructorArguments) {
    console.log(`verify  ${address} with arguments ${constructorArguments.join(',')}`);
    await run('verify:verify', {
        address,
        constructorArguments
    });
}
async function main() {
    const fundsWalletAddress = process.env.fundsWalletAddress;
    const owner = process.env.owner;
    const minerNftAddress = process.env.minerNftAddress;
    const nodeNftAddress = process.env.nodeNftAddress;
    const tokensAddresses = [process.env.tokensAddresses1, process.env.tokensAddresses2, process.env.tokensAddresses3];
    const minerRewardsInit = [
        process.env.minerRewardsInit1,
        process.env.minerRewardsInit2,
        process.env.minerRewardsInit3
    ];
    const nodeRewardsInit = [process.env.nodeRewardsInit1, process.env.nodeRewardsInit2, process.env.nodeRewardsInit3];

    const Rewards = await hre.ethers.deployContract('Rewards', [
        fundsWalletAddress,
        owner,
        minerNftAddress,
        nodeNftAddress,
        tokensAddresses,
        minerRewardsInit,
        nodeRewardsInit
    ]);

    console.log('Deploying Rewards...');
    await Rewards.waitForDeployment();
    console.log('Rewards deployed to:', Rewards.target);

    await new Promise((resolve) => setTimeout(resolve, 20000));
    verify(Rewards.target, [
        fundsWalletAddress,
        owner,
        minerNftAddress,
        nodeNftAddress,
        tokensAddresses,
        minerRewardsInit,
        nodeRewardsInit
    ]);
}
main();
