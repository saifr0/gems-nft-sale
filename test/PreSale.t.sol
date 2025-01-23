// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;
import { Test, console } from "../lib/forge-std/src/Test.sol";

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { ECDSA } from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import { MessageHashUtils } from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

import "../contracts/utils/Common.sol";
import { PreSale } from "contracts/Presale.sol";

import { AggregatorV3Interface, TokenRegistry } from "../contracts/TokenRegistry.sol";
import { IClaims } from "../contracts/interfaces/IClaims.sol";
import { ITokenRegistry } from "../contracts/interfaces/ITokenRegistry.sol";
import { IMinerNft } from "../contracts/interfaces/IMinerNft.sol";
import { INodeNft } from "../contracts/interfaces/INodeNft.sol";

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
    uint8 NFT_NF_GEMS = 20;

    address[] leaders;
    uint256[] percentages;

    IERC20 USDT = IERC20(0x6fEA2f1b82aFC40030520a6C49B0d3b652A65915);
    IERC20 USDC = IERC20(0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913);
    IERC20 WETH = IERC20(0x4200000000000000000000000000000000000006);
    IERC20 WBTC = IERC20(0xcbB7C0000aB88B473b1f5aFd9ef808440eed33Bf);
    IERC20 GEMS = IERC20(0x7Ddd14E3a173A5Db7bB8fd74b82b667F221492B9);

    address usdtFundWallet;
    address usdcFundWallet;
    address gemsFundWallet;

    uint256 privateKey;
    address user = 0x68a6649c2aFD27477945a22Af9e61b570FBE8ad0;
    PreSale public preSale;
    TokenRegistry public tokenRegistryContract;
    uint256[] nftPrices;

    address owner = 0xC0FC8954c62A45c3c0a13813Bd2A10d88D70750D;
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
    uint256 liquidityPercent = 100_000;

    uint256 tokensToSell = (hardCap * 1e30) / 0.01 ether; // total hardcap / first round price

    uint256 liquidityAmount = (hardCap * liquidityPercent) / 1_000_000;

    uint256 liquidityTokensAmount = (liquidityAmount * 1e30) / 0.0105 ether;

    function setUp() public {
        privateKey = vm.envUint("PRIVATE_KEY");
        signer = vm.addr(privateKey);

        usdtFundWallet = 0x5a52E96BAcdaBb82fd05763E25335261B270Efcb;
        usdcFundWallet = 0x5414d89a8bF7E99d732BC52f3e6A3Ef461c0C078;
        gemsFundWallet = 0xAFb979d9afAd1aD27C5eFf4E27226E3AB9e5dCC9;

        tokenRegistryContract = new TokenRegistry();
        console.log("tokenRegistryContract==", address(tokenRegistryContract));
        // minersPrices = [500000000];
        // nodesPrices = [500000000, 1000000000, 5000000000];

        leaders = [
            0x12eF0F1C99D8FD50fFd37cCd12B09Ef7f1213269,
            0x19A865ab3A6E9DD7ac716891B0080b2cB3ffb9fa,
            0x395bFD879A3AE7eC4E469e26c8C1d7BB2F9d77B9,
            0xF14aEB1Cb06c674B58D87D2Cc2dfc4b1e9f4EdB6,
            0xC0FC8954c62A45c3c0a13813Bd2A10d88D70750D
        ];

        percentages = [50000, 50000, 50000, 50000, 50000];

        // -----------------------------------  Price - Feed ----------------------------------- //

        tokenRegistry = address(tokenRegistryContract);
        IERC20[] memory tokens = new IERC20[](4);
        tokens[0] = IERC20(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);
        tokens[1] = USDT;
        tokens[2] = WETH;
        tokens[3] = WBTC;
        TokenRegistry.PriceFeedData[] memory priceFeeds = new TokenRegistry.PriceFeedData[](4);

        priceFeeds[0] = TokenRegistry.PriceFeedData({
            priceFeed: AggregatorV3Interface(0x71041dddad3595F9CEd3DcCFBe3D1F4b0a16Bb70),
            normalizationFactor: NFT_NF_ETH,
            tolerance: TOLERANCE_ETH
        });

        priceFeeds[1] = TokenRegistry.PriceFeedData({
            priceFeed: AggregatorV3Interface(0x7e860098F58bBFC8648a4311b374B1D669a2bc6B),
            normalizationFactor: NFT_NF_USDT_USDC,
            tolerance: TOLERANCE_USDT_USDC
        });

        priceFeeds[2] = TokenRegistry.PriceFeedData({
            priceFeed: AggregatorV3Interface(0x71041dddad3595F9CEd3DcCFBe3D1F4b0a16Bb70),
            normalizationFactor: NFT_NF_GEMS,
            tolerance: TOLERANCE_ETH
        });

        priceFeeds[3] = TokenRegistry.PriceFeedData({
            priceFeed: AggregatorV3Interface(0x64c911996D3c6aC71f9b455B1E8E7266BcbD848F),
            normalizationFactor: 20,
            tolerance: TOLERANCE_ETH
        });

        // tokenRegistryContract.initialize(signer);
        // console.log("initilized");

        // -----------------------------------  Price - Feed ----------------------------------- //

        // -----------------------------------  fund-user ----------------------------------- //

        deal(user, 1_000_000 * 1e18);
        console.log("hello  1");

        deal(address(USDT), user, 2323420_000_000000 * 1e6);
        // deal(address(GEMS), user, 100_000_000000 * 1e18);
        uint256[3] memory nodesNFTPrices = [uint256(1000000), uint256(2000000), uint256(3000000)];

        vm.startPrank(user);
        preSale = new PreSale(
            platform,
            platform,
            platform,
            signer,
            owner,
            IERC20(0x7Ddd14E3a173A5Db7bB8fd74b82b667F221492B9),
            IERC20(0x6fEA2f1b82aFC40030520a6C49B0d3b652A65915),
            IClaims(0x8803eE4671159e6a07067da6ee4789655125C089),
            IMinerNft(0x67aF8500a168DC4984d61FB12fC9394B8CF7339b),
            INodeNft(0x2E996eA23e1820f010d9cd9dc9ec3c8a5E8ABe3F),
            ITokenRegistry(0x07AA440a2cc116fB1C01BF135F6d7AFBdd36c57f),
            10_000_000,
            [uint256(10_000_000), uint256(20_000_000), uint256(30_000_000)]
        );
        console.log("preSale==", address(preSale));

        vm.stopPrank();
    }

    function testPurchase() external {
        uint256 deadline = 1737636228;
        console.log("-----   deadline   ------", deadline);
        console.log("-----   user   ------", user);

        // (uint8 v, bytes32 r, bytes32 s) = _validateSignWithToken(0, 0, USDT, deadline);

        // -------------------------------- purchases ------------------------------------------ //
        uint256 latestPriceGEMS = 1200000000;
        uint256 quantity = 10;

        vm.startPrank(signer);
        bytes32 msgHash = (keccak256(abi.encodePacked(user, "saif", percentages, leaders, deadline, USDT))).toEthSignedMessageHash();
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, msgHash);
        console.log(v);
        console.logBytes32(r);
        console.logBytes32(s);
        vm.stopPrank();

        vm.startPrank(user);
        USDT.forceApprove(address(preSale), USDT.balanceOf(user));

        //         v : 0x1c
        // r : 0xb5faf8e776eeb61fd527a5f4338778935203885f861af4351903bfbad5cd4e8b
        // s : 0x58e4b357d85a1a0d57220a65f0cee50b22e225cc824267f0a9447d6f4a6b7716

        preSale.purchaseMinerNFTDiscount(1, deadline, [uint(1), uint(0), uint(0)], percentages, leaders, "saif", v, r, s);
        // GEMS.forceApprove(address(preSale), GEMS.balanceOf(user));
        // preSale.purchaseMinersNFT(quantity, 8, 10000000, leaders, percentages, code, deadline);
        // preSale.purchaseNodeNFT(0, quantity, 8, 10000000, leaders, percentages, code, deadline);

        // 99995000
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
