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

    const nodeFundsWallet = '0x5d63cE81FAbaCf586A8fd4039Db08B59BE909D5b';
    const minerFundsWallet = '0x12eF0F1C99D8FD50fFd37cCd12B09Ef7f1213269';
    const signerAddress = '0x12eF0F1C99D8FD50fFd37cCd12B09Ef7f1213269';
    const owner = '0x12eF0F1C99D8FD50fFd37cCd12B09Ef7f1213269';
    const minerNftContractAddress = '0x2D3B57cDF8b369D1D068410a646B958bFd0307b4';
    const nodeNftContractAddress = '0x22CCE3574fDf658B4E2d0878160aC4Df8225bB2D';
    const tokenRegistryAddress = '0x07AA440a2cc116fB1C01BF135F6d7AFBdd36c57f';
    const priceAccretionPercentagePPMInit = '25000';
    const nodesNFTPriceInit = '99000000';
    const minersNFTPriceInit = ['199000000', '3999000000', '19999000000'];

    const prevAccretionThreshold = '895500000';
    const prevTotalRaised = '895500000';
    const currentWeek = 1;
    const currentWeekEndTime = '1739361960';

    // // // -------------------------------- CLAIMS------------------------------------------ //
    const Claims = await hre.ethers.deployContract('Claims', [owner, currentWeek, currentWeekEndTime]);
    console.log('Deploying Claims...');
    await Claims.waitForDeployment();
    console.log('Claims deployed to---------', Claims.target);
    await new Promise((resolve) => setTimeout(resolve, 30000));

    verify(Claims.target, [owner, currentWeek, currentWeekEndTime]);
    console.log('Claims Verified');

    // // -------------------------------- TokenRegistry------------------------------------------ //

    const PreSale = await hre.ethers.deployContract('PreSale', [
        nodeFundsWallet,
        minerFundsWallet,
        signerAddress,
        owner,
        Claims.target,
        minerNftContractAddress,
        nodeNftContractAddress,
        tokenRegistryAddress,
        nodesNFTPriceInit,
        prevAccretionThreshold,
        prevTotalRaised,
        priceAccretionPercentagePPMInit,
        minersNFTPriceInit
    ]);

    console.log('Deploying PreSale...');

    await PreSale.waitForDeployment();

    console.log('PreSale deployed to--------', PreSale.target);

    await new Promise((resolve) => setTimeout(resolve, 30000));

    verify(PreSale.target, [
        nodeFundsWallet,
        minerFundsWallet,
        signerAddress,
        owner,
        Claims.target,
        minerNftContractAddress,
        nodeNftContractAddress,
        tokenRegistryAddress,
        nodesNFTPriceInit,
        prevAccretionThreshold,
        prevTotalRaised,
        priceAccretionPercentagePPMInit,
        minersNFTPriceInit
    ]);

    console.log('PreSale Verified');

    let claims = await hre.ethers.getContractAt('Claims', Claims.target);

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
