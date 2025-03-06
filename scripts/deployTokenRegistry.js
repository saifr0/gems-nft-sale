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
    const owner = '0x5d63cE81FAbaCf586A8fd4039Db08B59BE909D5b';
    const TokenRegistry = await ethers.getContractFactory('TokenRegistry');
    console.log('Deploying TokenRegistry...');
    const contract = await upgrades.deployProxy(TokenRegistry, [owner], {
        initializer: 'initialize',
        kind: 'transparent'
    });
    await contract.waitForDeployment();
    console.log('TokenRegistry deployed to:', contract.target);

    await new Promise((resolve) => setTimeout(resolve, 30000));
    verify(contract.target, []);
}
main();
