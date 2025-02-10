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
    const fundwallets = [process.env.FUNDS_WALLET, process.env.FUNDS_WALLET2, process.env.FUNDS_WALLET3];
    const insurance = process.env.INSURANCE;
    const projectWallet = process.env.PROJECT_WALLET;
    const platFormWallet = process.env.PLATFORM_WALLET;
    const signer = process.env.SIGNER;
    const claim = process.env.CLAIMS;
    const lockup = process.env.LOCKUP;
    const owner = process.env.INITIAL_OWNER;
    const lastround = process.env.LAST_ROUND;
    const insurancePercentagePremiumPPH = process.env.INSURANCE_PERCENTAGE;
    const prices = [
        process.env.PRICES0,
        process.env.PRICES1,
        process.env.PRICES2,
        process.env.PRICES3,
        process.env.PRICES4,
        process.env.PRICES5
    ];

    const sortedWallets = fundwallets.sort((a, b) => a - b);

    const PreSale = await hre.ethers.deployContract('PreSale', [
        sortedWallets,
        insurance,
        projectWallet,
        platFormWallet,
        signer,
        claim,
        lockup,
        owner,
        lastround,
        insurancePercentagePremiumPPH,
        prices
    ]);

    console.log('Deploying PreSale...');
    await PreSale.waitForDeployment();
    console.log('PreSale deployed to:', PreSale.target);

    await new Promise((resolve) => setTimeout(resolve, 20000));
    verify(PreSale.target, [
        sortedWallets,
        insurance,
        projectWallet,
        platFormWallet,
        signer,
        claim,
        lockup,
        owner,
        lastround,
        insurancePercentagePremiumPPH,
        prices
    ]);
}
main();
