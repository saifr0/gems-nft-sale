// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;
import { Test, console } from "../lib/forge-std/src/Test.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { ECDSA } from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import { MessageHashUtils } from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "../contracts/utils/Common.sol";
import { PreSale } from "../contracts/Presale.sol";
import { Claims } from "../contracts/Claims.sol";
import { AggregatorV3Interface, TokenRegistry } from "../contracts/TokenRegistry.sol";
import { IClaims } from "../contracts/interfaces/IClaims.sol";
import { ITokenRegistry } from "../contracts/interfaces/ITokenRegistry.sol";
import { IMinerNft } from "../contracts/interfaces/IMinerNft.sol";
import { INodeNft } from "../contracts/interfaces/INodeNft.sol";
import { NodeNft } from "../contracts/nfts/NodeNft.sol";
import { MinerNft } from "../contracts/nfts/MinerNft.sol";

contract PreSaleTest is Test {
    using MessageHashUtils for bytes32;
    using SafeERC20 for IERC20;
    error OwnableUnauthorizedAccount(address);
    string code = "12345";
    uint32 round;
    uint256 minAmount = 1;
    uint256 roundPrice = 1 ether;
    uint8 TOKEN_NF_ETH = 10;
    uint8 NFT_NF_ETH = 20;
    uint256 TOLERANCE_ETH = 7200;
    uint8 TOKEN_NF_USDT_USDC = 22;
    uint8 NFT_NF_USDT_USDC = 8;
    uint256 TOLERANCE_USDT_USDC = 172800;
    uint8 TOKEN_NF_GEMS = 8;
    uint8 NFT_NF_GEMS = 22;
    address[] leaders;
    uint256[] percentages;
    IERC20 USDT = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);
    IERC20 USDC = IERC20(0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913);
    IERC20 WETH = IERC20(0x4200000000000000000000000000000000000006);
    IERC20 WBTC = IERC20(0xcbB7C0000aB88B473b1f5aFd9ef808440eed33Bf);
    IERC20 GEMS = IERC20(0x3010ccb5419F1EF26D40a7cd3F0d707a0fa127Dc);
    address usdtFundWallet;
    address usdcFundWallet;
    address gemsFundWallet;
    uint256 privateKey;
    address user = 0x5d63cE81FAbaCf586A8fd4039Db08B59BE909D5b;
    PreSale public preSale;
    Claims public claimsContract;
    TokenRegistry public tokenRegistryContract;
    NodeNft public nodeNftContract;
    MinerNft public minerNftContract;
    ERC1967Proxy proxy;
    uint256 accreationPercentage = 25000;
    uint256[] nftPrices;
    address owner = 0x5d63cE81FAbaCf586A8fd4039Db08B59BE909D5b;
    address funds = 0x3284cb59c9e03FdA920B31F22A692Bf7B93377F7;
    address platform = 0x3d4e44Eb1374240CE5F1B871ab261CD16335B76a;
    address signer;
    address tokenRegistry;
    address lockLiquidity;
    address universalRouter = 0x3fC91A3afd70395Cd496C647d5a6CC9D4B2b7FAD;
    address quoter = 0x3d4e44Eb1374240CE5F1B871ab261CD16335B76a;
    IERC20 presaleToken;
    IERC20 usdt = USDT;
    address positionManger = 0x03a520b32C04BF3bEEf7BEb72E919cf822Ed34f1;
    address factoryV3 = 0x33128a8fC17869897dcE68Ed026d694621f6FDfD;
    address permit = 0x000000000022D473030F116dDEE9F6B43aC78BA3;
    address nftPosition = 0x03a520b32C04BF3bEEf7BEb72E919cf822Ed34f1;
    address burnWallet = 0xF8D8febA05441201F6500197A41974071D6E8649;
    uint256[] startTimes;
    uint256[] endTimes;
    uint256[] prices;
    IERC20[][] allowedTokens;
    uint256[][] customPrices;
    uint160 launchPrice;
    uint256 referralCommission = 100_000; // in PPM
    uint256 hardCap = 1_000_000 * 10 ** 6;
    uint256 minBuy = 1;
    uint256 maxBuy = 500_000 * 10 ** 6;
    uint256 liquidityPercent = 100_0000;
    uint256[3] public minerNFTPrices = [uint256(100_000_000), uint256(200_0000), uint256(200_0000)];
    uint256 tokensToSell = (hardCap * 1e30) / 0.01 ether; // total hardcap / first round price
    uint256 liquidityAmount = (hardCap * liquidityPercent) / 1_000_000;
    uint256 liquidityTokensAmount = (liquidityAmount * 1e30) / 0.0105 ether;

    function setUp() public {
        privateKey = vm.envUint("PRIVATE_KEY_SEPOLIA");
        signer = vm.addr(privateKey);
        usdtFundWallet = 0x5a52E96BAcdaBb82fd05763E25335261B270Efcb;
        usdcFundWallet = 0x5414d89a8bF7E99d732BC52f3e6A3Ef461c0C078;
        gemsFundWallet = 0xAFb979d9afAd1aD27C5eFf4E27226E3AB9e5dCC9;
        nodeNftContract = new NodeNft(owner, "");
        console.log("nodeNftContract==", address(nodeNftContract));
        minerNftContract = new MinerNft(owner, "");
        console.log("minerNftContract==", address(minerNftContract));
        claimsContract = new Claims(funds);
        console.log("claimsContract==", address(claimsContract));
        tokenRegistryContract = new TokenRegistry();
        console.log("tokenRegistryContract==", address(tokenRegistryContract));
        leaders = [
            0x12eF0F1C99D8FD50fFd37cCd12B09Ef7f1213269,
            0x19A865ab3A6E9DD7ac716891B0080b2cB3ffb9fa,
            0x395bFD879A3AE7eC4E469e26c8C1d7BB2F9d77B9,
            0xF14aEB1Cb06c674B58D87D2Cc2dfc4b1e9f4EdB6,
            0xC0FC8954c62A45c3c0a13813Bd2A10d88D70750D
        ];
        percentages = [20000, 20000, 20000, 20000, 20000];
        // -----------------------------------  Price - Feed ----------------------------------- //
        proxy = new ERC1967Proxy(
            address(tokenRegistryContract),
            abi.encodeCall(tokenRegistryContract.initialize, (owner))
        );
        // use upgradable contract
        tokenRegistryContract = TokenRegistry(address(proxy));
        IERC20[] memory tokens = new IERC20[](2);
        tokens[0] = USDT;
        tokens[1] = USDC;

        TokenRegistry.PriceFeedData[] memory priceFeeds = new TokenRegistry.PriceFeedData[](2);
        priceFeeds[0] = TokenRegistry.PriceFeedData({
            priceFeed: AggregatorV3Interface(0x3E7d1eAB13ad0104d2750B8863b489D65364e32D),
            normalizationFactor: NFT_NF_USDT_USDC,
            tolerance: TOLERANCE_USDT_USDC
        });
        priceFeeds[1] = TokenRegistry.PriceFeedData({
            priceFeed: AggregatorV3Interface(0x8fFfFfd4AfB6115b954Bd326cbe7B4BA576818f6),
            normalizationFactor: NFT_NF_USDT_USDC,
            tolerance: TOLERANCE_USDT_USDC
        });
        vm.startPrank(owner);
        console.log("tokenRegistryContract price set time", address(tokenRegistryContract));
        tokenRegistryContract.setTokenPriceFeed(tokens, priceFeeds);
        console.log("price set");

        vm.stopPrank();

        // -----------------------------------  Price - Feed ----------------------------------- //
        // -----------------------------------  fund-user ----------------------------------- //
        deal(user, 1_000_000 * 1e18);
        console.log("hello  1");
        deal(address(USDT), user, 2323420_000_000000 * 1e6);
        deal(address(GEMS), user, 200000000000000000 * 1e18);
        vm.startPrank(user);

        preSale = new PreSale(
            funds,
            platform,
            signer,
            owner,
            IClaims(address(claimsContract)),
            IMinerNft(address(minerNftContract)),
            INodeNft(address(nodeNftContract)),
            ITokenRegistry(address(tokenRegistryContract)),
            1000000,
            25000,
            minerNFTPrices
        );
        console.log("preSale==", address(preSale));
        console.log("token registry in presale==", address(preSale.tokenRegistry()));
        nodeNftContract.updatePresaleAddress(address(preSale));
        minerNftContract.updatePresaleAddress(address(preSale));
        vm.stopPrank();
        claimsContract.updatePresaleAddress(address(preSale));

        IERC20[] memory allowedPresaleTokens = new IERC20[](4);
        allowedPresaleTokens[0] = USDT;
        allowedPresaleTokens[1] = USDC;
        allowedPresaleTokens[2] = WETH;
        allowedPresaleTokens[3] = GEMS;

        bool[] memory allowedPresaleStatus = new bool[](4);
        allowedPresaleStatus[0] = true;
        allowedPresaleStatus[1] = true;
        allowedPresaleStatus[2] = true;
        allowedPresaleStatus[3] = true;

        vm.startPrank(owner);
        preSale.updateAllowedTokens(allowedPresaleTokens, allowedPresaleStatus);
        vm.stopPrank();
    }

    function testNodePurhaseWithUSDT() external {
        uint256 deadline = block.timestamp;
        uint256 price = 0;
        uint8 nf = 0;
        vm.startPrank(signer);
        bytes32 msgHash = (keccak256(abi.encodePacked(user, uint8(nf), uint256(price), deadline, USDT)))
            .toEthSignedMessageHash();
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, msgHash);
        console.log(v);
        console.logBytes32(r);
        console.logBytes32(s);
        vm.stopPrank();

        vm.startPrank(user);
        USDT.forceApprove(address(preSale), USDT.balanceOf(user));
        //node buying
        preSale.purchaseNodeNFT(USDT, 1, price, deadline, nf, v, r, s);
        vm.stopPrank();
    }

    function testNodePurhaseWithGEMS() external {
        uint256 deadline = block.timestamp;
        uint256 price = 1000000000;
        uint8 nf = 22;
        vm.startPrank(signer);
        bytes32 msgHash = (keccak256(abi.encodePacked(user, uint8(nf), uint256(price), deadline, GEMS)))
            .toEthSignedMessageHash();
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, msgHash);
        vm.stopPrank();

        vm.startPrank(user);
        GEMS.forceApprove(address(preSale), GEMS.balanceOf(user));
        //node buying
        preSale.purchaseNodeNFT(GEMS, 1, price, deadline, nf, v, r, s);
        vm.stopPrank();
    }

    function testMinerPurhaseWithUSDT() external {
        uint256 deadline = block.timestamp;
        uint256 price = 0;
        uint8 nf = 0;
        vm.startPrank(signer);
        bytes32 msgHash = (keccak256(abi.encodePacked(user, uint8(nf), uint256(price), deadline, USDT)))
            .toEthSignedMessageHash();
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, msgHash);
        vm.stopPrank();

        vm.startPrank(user);
        USDT.forceApprove(address(preSale), USDT.balanceOf(user));
        //node buying
        preSale.purchaseMinerNFT(USDT, price, deadline, [uint(1), uint(0), uint(0)], nf, v, r, s);
        vm.stopPrank();
    }

    function testMinerPurhaseWithGEMS() external {
        uint256 deadline = block.timestamp;
        uint256 price = 1000000000;
        uint8 nf = 22;
        vm.startPrank(signer);
        bytes32 msgHash = (keccak256(abi.encodePacked(user, uint8(nf), uint256(price), deadline, GEMS)))
            .toEthSignedMessageHash();
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, msgHash);
        vm.stopPrank();

        vm.startPrank(user);
        GEMS.forceApprove(address(preSale), GEMS.balanceOf(user));
        //node buying
        preSale.purchaseMinerNFT(GEMS, price, deadline, [uint(1), uint(0), uint(0)], nf, v, r, s);
        vm.stopPrank();
    }

    function testMinerDiscountPurhaseWithUSDT() external {
        uint256 deadline = block.timestamp;
        uint256 price = 0;
        uint8 nf = 0;
        vm.startPrank(signer);
        bytes32 msgHash = (
            keccak256(abi.encodePacked(user, code, percentages, leaders, uint8(nf), uint256(price), deadline, USDT))
        ).toEthSignedMessageHash();
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, msgHash);
        vm.stopPrank();

        vm.startPrank(user);
        USDT.forceApprove(address(preSale), USDT.balanceOf(user));
        //node buying
        preSale.purchaseMinerNFTDiscount(
            USDT,
            price,
            deadline,
            [uint(2), uint(0), uint(0)],
            percentages,
            leaders,
            nf,
            code,
            v,
            r,
            s
        );
        vm.stopPrank();

        uint256[] memory week = new uint256[](1);
        week[0] = 1;

        IERC20[][] memory token = new IERC20[][](1);
        IERC20[] memory claimtoken = new IERC20[](1);
        claimtoken[0] = USDT;
        token[0] = claimtoken;

        vm.warp(block.timestamp + 7 days);
        console.log("claims contract total USDT", USDT.balanceOf(address(claimsContract)));

        vm.startPrank(0x12eF0F1C99D8FD50fFd37cCd12B09Ef7f1213269);
        claimsContract.claimAll(week, token);
        console.log("claims contract USDT==1", USDT.balanceOf(address(claimsContract)));
        vm.stopPrank();
        vm.startPrank(0x19A865ab3A6E9DD7ac716891B0080b2cB3ffb9fa);
        claimsContract.claimAll(week, token);
        console.log("claims contract USDT==2", USDT.balanceOf(address(claimsContract)));
        vm.stopPrank();
        vm.startPrank(0x395bFD879A3AE7eC4E469e26c8C1d7BB2F9d77B9);
        claimsContract.claimAll(week, token);
        console.log("claims contract USDT==3", USDT.balanceOf(address(claimsContract)));
        vm.stopPrank();
        vm.startPrank(0xF14aEB1Cb06c674B58D87D2Cc2dfc4b1e9f4EdB6);
        claimsContract.claimAll(week, token);
        console.log("claims contract USDT==4", USDT.balanceOf(address(claimsContract)));
        vm.stopPrank();
        vm.startPrank(0xC0FC8954c62A45c3c0a13813Bd2A10d88D70750D);
        claimsContract.claimAll(week, token);
        console.log("claims contract USDT==5", USDT.balanceOf(address(claimsContract)));
        vm.stopPrank();
    }

    function testMinerDiscountPurhaseWithGEMS() external {
        uint256 deadline = block.timestamp;
        uint256 price = 1000000000;
        uint8 nf = 22;
        vm.startPrank(signer);
        bytes32 msgHash = (
            keccak256(abi.encodePacked(user, code, percentages, leaders, uint8(nf), uint256(price), deadline, GEMS))
        ).toEthSignedMessageHash();
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, msgHash);
        vm.stopPrank();

        vm.startPrank(user);
        GEMS.forceApprove(address(preSale), GEMS.balanceOf(user));
        //node buying
        preSale.purchaseMinerNFTDiscount(
            GEMS,
            price,
            deadline,
            [uint(2), uint(0), uint(0)],
            percentages,
            leaders,
            nf,
            code,
            v,
            r,
            s
        );
        vm.stopPrank();

        uint256[] memory week = new uint256[](1);
        week[0] = 1;

        IERC20[][] memory token = new IERC20[][](1);
        IERC20[] memory claimtoken = new IERC20[](1);
        claimtoken[0] = GEMS;
        token[0] = claimtoken;

        vm.warp(block.timestamp + 7 days);
        console.log("claims contract total GEMS", GEMS.balanceOf(address(claimsContract)));

        vm.startPrank(0x12eF0F1C99D8FD50fFd37cCd12B09Ef7f1213269);
        claimsContract.claimAll(week, token);
        console.log("claims contract GEMS==1", GEMS.balanceOf(address(claimsContract)));
        vm.stopPrank();
        vm.startPrank(0x19A865ab3A6E9DD7ac716891B0080b2cB3ffb9fa);
        claimsContract.claimAll(week, token);
        console.log("claims contract GEMS==2", GEMS.balanceOf(address(claimsContract)));
        vm.stopPrank();
        vm.startPrank(0x395bFD879A3AE7eC4E469e26c8C1d7BB2F9d77B9);
        claimsContract.claimAll(week, token);
        console.log("claims contract GEMS==3", GEMS.balanceOf(address(claimsContract)));
        vm.stopPrank();
        vm.startPrank(0xF14aEB1Cb06c674B58D87D2Cc2dfc4b1e9f4EdB6);
        claimsContract.claimAll(week, token);
        console.log("claims contract GEMS==4", GEMS.balanceOf(address(claimsContract)));
        vm.stopPrank();
        vm.startPrank(0xC0FC8954c62A45c3c0a13813Bd2A10d88D70750D);
        claimsContract.claimAll(week, token);
        console.log("claims contract GEMS==5", GEMS.balanceOf(address(claimsContract)));
        vm.stopPrank();
    }

    function _validateSignWithToken(
        uint256 referenceTokenPrice,
        uint256 normalizationFactor,
        IERC20 token,
        uint256 deadline
    ) private returns (uint8, bytes32, bytes32) {
        vm.startPrank(signer);
        bytes32 mhash = keccak256(abi.encodePacked(user, referenceTokenPrice, deadline, token, normalizationFactor));
        bytes32 msgHash = mhash.toEthSignedMessageHash();
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, msgHash);
        vm.stopPrank();
        return (v, r, s);
    }
}
