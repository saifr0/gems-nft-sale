const hre = require('hardhat');
const { ethers } = require('hardhat');
async function verify(address, constructorArguments) {
    console.log(`verify ${address} with arguments ${constructorArguments.join(',')}`);
    await run('verify:verify', {
        address,
        constructorArguments
    });
}
async function main() {
    await hre.run('compile');

    const minerFundsWallet = '0x3785744Cb6678f589986062250444Bb6932a2d8C';
    const minerNftContractAddress = '0x825778E24b6f059549294710C67f4539D9960E54';
    const nodeFundsWallet = '0x7B6b771DF9ECEFb3Df170aC94454C73519436799';
    const nodeNftContractAddress = '0x020B1594ccD0ebA1a39E854aF22e7f0083AE3ae6';
    const insuranceFundsWalletAddress = '0xc976fa8bc20ED2e6812dC77b4485CE573F6DE46d';
    const signerAddress = '0x8002917a84DB1B1Ef57f7Cf0B19f5F5c611db9D5';
    const owner = '0x3B764564639032F61fdA5360727577A4CbCe75cB';
    const tokenRegistryAddress = '0x2DAE9ac095df77755ae2ceD6AdDdD178701027df';
    const priceAccretionPercentagePPMInit = '25000';
    const nodesNFTPriceInit = '99000000';
    const minersNFTPriceInit = ['203975000', '4098975000', '20498975000'];

    const prevAccretionThreshold = '191196187500';
    const prevTotalRaised = '1191196187500';
    const currentWeek = '6';
    const insuranceFeePPM = '50000';
    // const currentWeekEndTime = '';

    // // // -------------------------------- CLAIMS------------------------------------------ //
    // const Claims = await hre.ethers.deployContract('Claims', [owner, currentWeek]);
    // console.log('Deploying Claims...');
    // await Claims.waitForDeployment();
    // console.log('Claims deployed to---------', Claims.target);
    // await new Promise((resolve) => setTimeout(resolve, 30000));

    verify('0x0F8d011aEc647ECD601dE4e3CD7774BeB03b4507', [owner, currentWeek]);
    console.log('Claims Verified');

    // // -------------------------------- TokenRegistry------------------------------------------ //

    const PreSale = await hre.ethers.deployContract('PreSale', [
        nodeFundsWallet,
        minerFundsWallet,
        insuranceFundsWalletAddress,
        signerAddress,
        owner,
        '0x0F8d011aEc647ECD601dE4e3CD7774BeB03b4507',
        minerNftContractAddress,
        nodeNftContractAddress,
        tokenRegistryAddress,
        nodesNFTPriceInit,
        prevAccretionThreshold,
        prevTotalRaised,
        priceAccretionPercentagePPMInit,
        insuranceFeePPM,
        minersNFTPriceInit
    ]);

    console.log('Deploying PreSale...');

    await PreSale.waitForDeployment();

    console.log('PreSale deployed to--------', PreSale.target);

    await new Promise((resolve) => setTimeout(resolve, 30000));

    verify(PreSale.target, [
        nodeFundsWallet,
        minerFundsWallet,
        insuranceFundsWalletAddress,
        signerAddress,
        owner,
        '0x0F8d011aEc647ECD601dE4e3CD7774BeB03b4507',
        minerNftContractAddress,
        nodeNftContractAddress,
        tokenRegistryAddress,
        nodesNFTPriceInit,
        prevAccretionThreshold,
        prevTotalRaised,
        priceAccretionPercentagePPMInit,
        insuranceFeePPM,
        minersNFTPriceInit
    ]);

    console.log('PreSale Verified');

    let claims = await hre.ethers.getContractAt('Claims', '0x0F8d011aEc647ECD601dE4e3CD7774BeB03b4507');

    await claims.updatePresaleAddress(PreSale.target);

    return;

    // let claims = await hre.ethers.getContractAt('Claims', Claims.target);
    // await claims.updatePresaleAddress(PreSale.target);

    // const wallet = await hre.ethers.Wallet(process.env.PV_SIGNER);

    // let minerNFT = await hre.ethers.getContractAt('MinerNft', MinerNFT.target);
    // minerNFT = minerNFT.connect(wallet);
    // await minerNFT.updatePresaleAddress(PreSale.target);

    // let nodeNFT = await hre.ethers.getContractAt('NodeNft', NodeNft.target);
    // nodeNFT = nodeNFT.connect(wallet);
    // await nodeNFT.updatePresaleAddress(PreSale.target);

    // return;

    // -----------------------------------  Price - Feed ----------------------------------- //
    const tokenRegistry = await hre.ethers.getContractAt('TokenRegistry', tokenRegistry.target);
    const priceFeedTokens = [ETH, USDC, WBTC, LINK];
    const priceFeedData = [
        {
            priceFeed: '0x71041dddad3595F9CEd3DcCFBe3D1F4b0a16Bb70', // ETH price feed
            normalizationFactorForToken: TOKEN_NF_ETH,
            tolerance: TOLERANCE_ETH
        },
        {
            priceFeed: '0x7e860098F58bBFC8648a4311b374B1D669a2bc6B', // USDT price feed
            normalizationFactorForToken: TOKEN_NF_USDT_USDC,
            normalizationFactorForNFT: NFT_NF_USDT_USDC,
            tolerance: TOLERANCE_USDT_USDC
        },
        {
            priceFeed: '0x71041dddad3595F9CEd3DcCFBe3D1F4b0a16Bb70', // WETH price feed
            normalizationFactorForToken: TOKEN_NF_USDT_USDC,
            normalizationFactorForNFT: NFT_NF_USDT_USDC,
            tolerance: TOLERANCE_USDT_USDC
        },
        {
            priceFeed: '0x64c911996D3c6aC71f9b455B1E8E7266BcbD848F', // WBTC price feed
            normalizationFactorForToken: TOKEN_NF_WBTC,
            normalizationFactorForNFT: NFT_NF_WBTC,
            tolerance: TOLERANCE_WBTC
        }
    ];
    tokenRegistry.setTokenPriceFeed(priceFeedTokens, priceFeedData);
    console.log('Pricefeed Set');

    //   // -------------------------------- Implementation(Presale)------------------------------------------ //
    // const PreSale = await hre.ethers.deployContract('PreSale', []);
    // console.log('Deploying PreSale...');
    // await PreSale.waitForDeployment();
    // console.log('PreSale deployed to:', PreSale.target);
    // await new Promise((resolve) => setTimeout(resolve, 200));
    // verify(PreSale.target, []);
    // console.log('PreSale Verified');

    //   // -------------------------------- BEACON------------------------------------------ //
    const implementation = await hre.ethers.getContractAt('PreSale', PreSale.target);

    const Beacon = await hre.ethers.deployContract('Beacon', [implementation.target, ownerAddress]);
    console.log('Deploying Beacon...');
    await Beacon.waitForDeployment();
    console.log('Beacon deployed to:', Beacon.target);
    await new Promise((resolve) => setTimeout(resolve, 200));
    verify(Beacon.target, [implementation.target, ownerAddress]);
    console.log('Beacon Verified');

    //   // -------------------------------- ProxyFactory------------------------------------------ //
    const ProxyFactory = await hre.ethers.deployContract('ProxyFactory', [
        tokenRegistryAddress,
        platformWalletAddress,
        ownerAddress,
        signerAddress,
        feeAmount
    ]);
    console.log('Deploying ProxyFactory...');
    await ProxyFactory.waitForDeployment();
    console.log('ProxyFactory deployed to:', ProxyFactory.target);
    await new Promise((resolve) => setTimeout(resolve, 200));

    verify(ProxyFactory.target, [tokenRegistryAddress, platformWalletAddress, ownerAddress, signerAddress, feeAmount]);
    console.log('BeaconProxyFactory Verified');

    //   // -----------------------------------  grant-admin-role-to-factory ----------------------------------- //

    const lockLiquidityContract = await hre.ethers.getContractAt('LockLiquidity', LockLiquidity.target);

    await lockLiquidityContract.grantRole(ADMIN_ROLE, owner);
    console.log('Has role:::');
    // -------------------------------- Creating Presale------------------------------------------ //

    const proxyFactoryContract = await hre.ethers.getContractAt('ProxyFactory', ProxyFactory.target);
    const beaconContract = await hre.ethers.getContractAt('Beacon', Beacon.target);

    console.log('ProxyFactory:::', proxyFactoryContract);

    //PresaleToken needs to be in contracts for getting presaleToken contract
    const presaleToken = await hre.ethers.getContractAt('PresaleToken', data.presaleTokenContractAddress);
    console.log('presaleToken===', presaleToken);

    const amount = await presaleToken.balanceOf(ownerAddress);
    console.log('amount==', amount);

    const tx1 = await presaleToken.approve(proxyFactoryContract, amount);
    await tx1.wait();
    console.log('approval done');

    const allowance = await presaleToken.allowance(ownerAddress, proxyFactoryContract);
    console.log('Allowance:', allowance.toString());

    //creating presale
    //*owner is serving as sale token wallet
    const tx = await proxyFactoryContract.createProxy(beaconContract, data, ownerAddress);

    const receipt = await tx.wait();
    console.log('Transaction hash:', tx.hash);
    console.log('Transaction receipt:', receipt);
}

main();
