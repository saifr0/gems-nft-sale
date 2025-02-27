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
import { Insurance } from "../contracts/Insurance.sol";

import { Claims } from "../contracts/Claims.sol";
import { AggregatorV3Interface, TokenRegistry } from "../contracts/TokenRegistry.sol";
import { IClaims } from "../contracts/interfaces/IClaims.sol";
import { ITokenRegistry } from "../contracts/interfaces/ITokenRegistry.sol";
import { IMinerNft } from "../contracts/interfaces/IMinerNft.sol";
import { INodeNft } from "../contracts/interfaces/INodeNft.sol";
import { NodeNft } from "../contracts/nfts/NodeNft.sol";
import { MinerNft } from "../contracts/nfts/MinerNft.sol";
import { IMiner } from "../contracts/interfaces/IMiner.sol";

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
    IERC20 insuranceTokens;
    uint256 insurancePrices;
    // uint256[] percentages;

    IERC20 USDT = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);
    IERC20 USDC = IERC20(0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913);
    IERC20 WETH = IERC20(0x4200000000000000000000000000000000000006);
    IERC20 WBTC = IERC20(0xcbB7C0000aB88B473b1f5aFd9ef808440eed33Bf);
    IERC20 GEMS = IERC20(0x3010ccb5419F1EF26D40a7cd3F0d707a0fa127Dc);

    uint256 privateKey;
    address signer;
    address user = 0x5d63cE81FAbaCf586A8fd4039Db08B59BE909D5b;
    PreSale public preSale;
    Insurance public insurance;

    Claims public claimsContract;
    TokenRegistry public tokenRegistryContract;
    NodeNft public nodeNftContract;
    MinerNft public minerNftContract;
    ERC1967Proxy proxy;
    uint256 accreationPercentage = 25000;
    address owner = 0x5d63cE81FAbaCf586A8fd4039Db08B59BE909D5b;
    address funds = 0x3284cb59c9e03FdA920B31F22A692Bf7B93377F7;
    address platform = 0x3d4e44Eb1374240CE5F1B871ab261CD16335B76a;
    uint256[3] public minerNFTPrices = [uint256(100_000_000), uint256(100_000_000), uint256(100_000_000)];

    function setUp() public {
        privateKey = vm.envUint("PRIVATE_KEY_SEPOLIA");
        signer = vm.addr(privateKey);
        nodeNftContract = new NodeNft(owner, "");
        minerNftContract = new MinerNft(owner, "");
        claimsContract = new Claims(funds, 1, block.timestamp);
        tokenRegistryContract = new TokenRegistry();
        leaders = [
            0x12eF0F1C99D8FD50fFd37cCd12B09Ef7f1213269,
            0x19A865ab3A6E9DD7ac716891B0080b2cB3ffb9fa,
            0x395bFD879A3AE7eC4E469e26c8C1d7BB2F9d77B9,
            0xF14aEB1Cb06c674B58D87D2Cc2dfc4b1e9f4EdB6,
            0xC0FC8954c62A45c3c0a13813Bd2A10d88D70750D
        ];
        percentages = [50000, 50000, 50000, 20000, 30000];

        insuranceTokens = ETH;
        insurancePrices = 2000340;
        // -----------------------------------  Price - Feed ----------------------------------- //
        proxy = new ERC1967Proxy(
            address(tokenRegistryContract),
            abi.encodeCall(tokenRegistryContract.initialize, (owner))
        );
        // use upgradable contract
        tokenRegistryContract = TokenRegistry(address(proxy));
        IERC20[] memory tokens = new IERC20[](3);
        tokens[0] = USDT;
        tokens[1] = USDC;
        tokens[2] = ETH;

        TokenRegistry.PriceFeedData[] memory priceFeeds = new TokenRegistry.PriceFeedData[](3);
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

        priceFeeds[2] = TokenRegistry.PriceFeedData({
            priceFeed: AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419),
            normalizationFactor: NFT_NF_ETH,
            tolerance: TOLERANCE_ETH
        });
        vm.startPrank(owner);
        tokenRegistryContract.setTokenPriceFeed(tokens, priceFeeds);
        vm.stopPrank();

        // -----------------------------------  Price - Feed ----------------------------------- //
        // -----------------------------------  fund-user ----------------------------------- //
        deal(user, 100 * 1e18);
        deal(address(USDT), user, 2323420_000_000000 * 1e6);
        deal(address(GEMS), user, 200000000000000000 * 1e18);
        // vm.startPrank(user);

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
            0,
            0,
            25000,
            minerNFTPrices
        );

        insurance = new Insurance(
            funds,
            signer,
            owner,
            IMiner(address(minerNftContract)),
            ITokenRegistry(address(tokenRegistryContract))
        );

        vm.startPrank(owner);
        nodeNftContract.updatePresaleAddress(address(preSale));
        minerNftContract.updatePresaleAddress(address(preSale));
        vm.stopPrank();
        claimsContract.updatePresaleAddress(address(preSale));

        IERC20[] memory allowedPresaleTokens = new IERC20[](4);
        allowedPresaleTokens[0] = USDT;
        allowedPresaleTokens[1] = USDC;
        allowedPresaleTokens[2] = ETH;
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

    function testMinerPurchaseWithUSDT() external {
        uint256 expectedMinerWalletFunds;
        uint256 prices;

        uint256 deadline = block.timestamp;
        uint256 price = 0;
        uint8 nf = 0;
        bool isInsured = true;
        string memory trxHash = "0x2b120b172ee2e96da9a497593c03aaaac0c268680a0e2f75e7465ce2fa9c9fb6";
        uint256[3] memory quantities = [uint(1), uint(2), uint(3)];
        uint256[3] memory quantities1 = [uint(1), uint(2), uint(3)];
        uint256[3] memory quantities4 = [uint(0), uint(2), uint(6)];

        //sign
        (uint8 v, bytes32 r, bytes32 s) = _validateSignWithToken(price, nf, ETH, deadline);
        (uint8 v1, bytes32 r1, bytes32 s1) = _validateSignInsurance(
            ETH,
            minerNFTPrices,
            quantities1,
            price,
            nf,
            trxHash,
            deadline
        );

        // (uint8 v4, bytes32 r4, bytes32 s4) = _validateSignInsurance(
        //     insuranceTokens,
        //     insurancePrices,
        //     quantities4,
        //     deadline
        // );

        // getting ETH latest price and normalization factor
        uint256 latestPriceUSDT = tokenRegistryContract.getLatestPrice(IERC20(ETH)).latestPrice;
        uint8 nfUSDT = tokenRegistryContract.getLatestPrice(IERC20(ETH)).normalizationFactor;

        //calaculating nft purchasing amount
        uint256[3] memory minerPrices = minerNFTPrices;
        uint256 quantityLength = quantities.length;

        for (uint256 i; i < quantityLength; ++i) {
            uint256 quantity = quantities[i];

            if (quantity > 0) {
                prices += (minerPrices[i] * quantity);
            }
        }

        // expectedMinerWalletFunds = (prices * (10 ** nfUSDT)) / latestPriceUSDT;

        //sign
        // (uint8 v2, bytes32 r2, bytes32 s2) = _validateSignWithTokenDiscounted(price, nf, 100000, ETH, deadline, true);

        //miner buying
        vm.startPrank(user);
        USDT.forceApprove(address(preSale), USDT.balanceOf(user));
        USDT.forceApprove(address(insurance), USDT.balanceOf(user));
        preSale.purchaseMinerNFT{ value: 50 ether }(ETH, price, deadline, quantities, nf, v, r, s);
        // preSale.purchaseMinerNFTDiscount{ value: 50 ether }(
        //     ETH,
        //     price,
        //     deadline,
        //     100000,
        //     quantities,
        //     percentages,
        //     leaders,
        //     nf,
        //     true,
        //     code,
        //     v2,
        //     r2,
        //     s2
        // );
        console.log("balance---", user.balance);
        insurance.purchaseInsurance{ value: 1 ether }(
            ETH,
            minerNFTPrices,
            deadline,
            quantities1,
            price,
            nf,
            trxHash,
            v1,
            r1,
            s1
        );

        vm.stopPrank();

        // //miner and user walllet balance assertion
        // assertEq(USDT.balanceOf(preSale.minerFundsWallet()), expectedMinerWalletFunds, "Miner Wallet Funds");

        // //user nft balance assertions
        // for (uint256 i; i < quantityLength; ++i) {
        //     uint256 quantity = quantities[i];
        //     if (quantity > 0) {
        //         uint256 tokenId = i;
        //         uint256 userBalance = minerNftContract.balanceOf(user, tokenId);

        //         assertEq(userBalance, quantity, "user Nfts");
        //     }
        // }
    }

    function _validateSignWithToken(
        uint256 referenceTokenPrice,
        uint256 normalizationFactor,
        IERC20 token,
        uint256 deadline
    ) private returns (uint8, bytes32, bytes32) {
        vm.startPrank(signer);
        bytes32 msgHash = (
            keccak256(abi.encodePacked(user, uint8(normalizationFactor), uint256(referenceTokenPrice), deadline, token))
        ).toEthSignedMessageHash();
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, msgHash);
        vm.stopPrank();
        return (v, r, s);
    }

    function _validateSignInsurance(
        IERC20 tokens,
        uint256[3] memory prices,
        uint256[3] memory quantities,
        uint256 referenceTokenPrice,
        uint8 normalizationFactor,
        string memory trxHash,
        uint256 deadline
    ) private returns (uint8, bytes32, bytes32) {
        vm.startPrank(signer);
        bytes32 msgHash = (
            keccak256(
                abi.encodePacked(
                    user,
                    tokens,
                    prices,
                    quantities,
                    referenceTokenPrice,
                    normalizationFactor,
                    trxHash,
                    deadline
                )
            )
        ).toEthSignedMessageHash();
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, msgHash);
        vm.stopPrank();
        return (v, r, s);
    }

    function _validateSignWithTokenDiscounted(
        uint256 referenceTokenPrice,
        uint256 normalizationFactor,
        uint256 discount_percentage_ppm,
        IERC20 token,
        uint256 deadline,
        bool isInsured
    ) private returns (uint8, bytes32, bytes32) {
        vm.startPrank(signer);
        bytes32 msgHash = (
            keccak256(
                abi.encodePacked(
                    user,
                    code,
                    percentages,
                    leaders,
                    discount_percentage_ppm,
                    uint8(normalizationFactor),
                    uint256(referenceTokenPrice),
                    deadline,
                    token,
                    isInsured
                )
            )
        ).toEthSignedMessageHash();
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, msgHash);
        vm.stopPrank();
        return (v, r, s);
    }
}
