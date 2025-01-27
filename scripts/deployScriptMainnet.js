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
    // -------------------------------- blocktimstamp ------------------------------------------ //
    let now = Date.now(); // Unix timestamp in milliseconds
    now = now / 1000;
    now = Math.trunc(now);

    const ETH = '0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE';
    // const USDC = '0x833589fcd6edb6e08f4c7c32d4f71b54bda02913';
    // const WETH = '0x4200000000000000000000000000000000000006';
    // const WBTC = '0xcbb7c0000ab88b473b1f5afd9ef808440eed33bf';

    const projectWalletAddress = '0x5d63cE81FAbaCf586A8fd4039Db08B59BE909D5b';
    const platformWalletAddress = '0x0cFA15E360B968E4706050A4FebeB57bdb8C5701';
    const burnWalletAddress = '0xDebaDF0D39dD5f1819FE609c4d143610E771236A';
    const signerAddress = '0x12eF0F1C99D8FD50fFd37cCd12B09Ef7f1213269';
    const owner = '0x12eF0F1C99D8FD50fFd37cCd12B09Ef7f1213269';
    const gemsAddress = '0x7Ddd14E3a173A5Db7bB8fd74b82b667F221492B9';
    const usdtAddress = '0x6fea2f1b82afc40030520a6c49b0d3b652a65915';
    const claimsContractAddress = '0xDc091260C305339f6dc0e55e58F24ea2131e37bB';
    const minerNftContractAddress = '';
    const nodeNftContractAddress = '';
    const tokenRegistryAddress = '0x07AA440a2cc116fB1C01BF135F6d7AFBdd36c57f';
    const nodesNFTPriceInit = '100000000';
    const minersNFTPriceInit = ['50000000', '100000000', '150000000'];

    // -------------------------------- TokenRegistry------------------------------------------ //
    //*this is simple token registry deployment script, not the upgradable

    // const TokenRegistry = await ethers.getContractFactory('TokenRegistry');
    // console.log('Deploying TokenRegistry...');
    // const contract = await upgrades.deployProxy(TokenRegistry, [owner], {
    //     initializer: 'initialize',
    //     kind: 'transparent'
    // });
    // await contract.waitForDeployment();
    // console.log('TokenRegistry deployed to:', contract.target);

    // await new Promise((resolve) => setTimeout(resolve, 20000));
    // verify(contract.target, []);
    // return;

    //------------------------------- MinerNFT------------------------------------------ //

    // const MinerNFT = await hre.ethers.deployContract('MinerNft', [owner]);
    // console.log('Deploying MinerNFT...');
    // await MinerNFT.waitForDeployment();
    // console.log('MinerNFT deployed to -------', MinerNFT.target);
    // await new Promise((resolve) => setTimeout(resolve, 20000));
    // verify(MinerNFT.target, [owner]);
    // console.log('MinerNFT Verified');
    // // return;

    // // // -------------------------------- NodeNft------------------------------------------ //
    // const NodeNft = await hre.ethers.deployContract('NodeNft', [owner]);
    // console.log('Deploying NodeNft...');
    // await NodeNft.waitForDeployment();
    // console.log('NodeNft deployed to---------', NodeNft.target);
    // await new Promise((resolve) => setTimeout(resolve, 20000));
    // verify(NodeNft.target, [owner]);
    // console.log('NodeNft Verified');
    // // return;

    // // // -------------------------------- CLAIMS------------------------------------------ //
    // const Claims = await hre.ethers.deployContract('Claims', [projectWalletAddress, usdtAddress]);
    // console.log('Deploying Claims...');
    // await Claims.waitForDeployment();
    // console.log('Claims deployed to---------', Claims.target);
    // await new Promise((resolve) => setTimeout(resolve, 20000));
    // verify(Claims.target, [projectWalletAddress, usdtAddress]);
    // console.log('Claims Verified');
    // return;

    // // -------------------------------- TokenRegistry------------------------------------------ //

    // const PreSale = await hre.ethers.deployContract('PreSale', [
    //     projectWalletAddress,
    //     signerAddress,
    //     owner,
    //     gemsAddress,
    //     usdtAddress,
    //     '0x82095F9a2288Cb0e6A7D219740561EA2C60E2d7f',
    //     '0xAC258a8396B0Efa2B049AaC0C4E3Bbc37DCB24C8',
    //     '0x3ECd838B3DF14B12593852576f272Ed21Ea66aaf',
    //     tokenRegistryAddress,
    //     nodesNFTPriceInit,
    //     minersNFTPriceInit
    // ]);
    // console.log('Deploying PreSale...');
    // await PreSale.waitForDeployment();
    // console.log('PreSale deployed to--------', PreSale.target);
    // await new Promise((resolve) => setTimeout(resolve, 20000));

    verify('0x93ce795a118e5562cfcc79e3685f49f44365f50c', [
        projectWalletAddress,
        signerAddress,
        owner,
        gemsAddress,
        usdtAddress,
        '0x82095F9a2288Cb0e6A7D219740561EA2C60E2d7f',
        '0xAC258a8396B0Efa2B049AaC0C4E3Bbc37DCB24C8',
        '0x3ECd838B3DF14B12593852576f272Ed21Ea66aaf',
        tokenRegistryAddress,
        nodesNFTPriceInit,
        minersNFTPriceInit
    ]);

    console.log('PreSale Verified');
    let claims = await hre.ethers.getContractAt('Claims', '0x82095F9a2288Cb0e6A7D219740561EA2C60E2d7f');
    await claims.updatePresaleAddress('0x93ce795a118e5562cfcc79e3685f49f44365f50c');
    return;

    // MinerNFT deployed to ------- 0xAC258a8396B0Efa2B049AaC0C4E3Bbc37DCB24C8
    // NodeNft deployed to  ------- 0x3ECd838B3DF14B12593852576f272Ed21Ea66aaf
    // Claims deployed to   ------

    // PreSale deployed to-------- 0x93ce795a118e5562cfcc79e3685f49f44365f50c

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
