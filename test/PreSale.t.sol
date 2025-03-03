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

    uint256 privateKey;
    address signer;
    address user = 0x5d63cE81FAbaCf586A8fd4039Db08B59BE909D5b;
    PreSale public preSale;
    Claims public claimsContract;
    TokenRegistry public tokenRegistryContract;
    NodeNft public nodeNftContract;
    MinerNft public minerNftContract;
    ERC1967Proxy proxy;
    uint256 accreationPercentage = 25000;
    address insurance = 0xF14aEB1Cb06c674B58D87D2Cc2dfc4b1e9f4EdB6;
    address owner = 0x5d63cE81FAbaCf586A8fd4039Db08B59BE909D5b;
    address funds = 0x3284cb59c9e03FdA920B31F22A692Bf7B93377F7;
    address platform = 0x3d4e44Eb1374240CE5F1B871ab261CD16335B76a;
    uint256[3] public minerNFTPrices = [uint256(100_000_000), uint256(200_0000), uint256(200_0000)];

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
        percentages = [50000, 50000, 50000, 50000, 50000];
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
        deal(user, 1 * 1e18);
        deal(address(USDT), user, 2323420_000_000000 * 1e6);
        deal(address(GEMS), user, 200000000000000000 * 1e18);
        vm.startPrank(user);

        preSale = new PreSale(
            funds,
            platform,
            insurance,
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
            50000,
            minerNFTPrices
        );
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

    function testNodePurchaseWithETH() external {
        uint256 expectedNodeWalletFunds;
        uint256 expectedUserPayment;
        uint256 prices;

        uint256 deadline = block.timestamp;
        uint256 price = 0;
        uint8 nf = 0;

        //sign
        (uint8 v, bytes32 r, bytes32 s) = _validateSignWithTokenNode(price, nf, ETH, deadline);

        //getting ETH latest price and normalization factor
        uint256 latestPriceETH = tokenRegistryContract.getLatestPrice(IERC20(ETH)).latestPrice;
        uint8 nfETH = tokenRegistryContract.getLatestPrice(IERC20(ETH)).normalizationFactor;

        //calaculating nft purchasing amount
        uint256 quantities = 5;
        prices = preSale.nodeNFTPrice() * quantities;
        expectedNodeWalletFunds = (prices * (10 ** nfETH)) / latestPriceETH;
        expectedUserPayment = user.balance - expectedNodeWalletFunds;

        //node buying
        vm.startPrank(user);
        preSale.purchaseNodeNFT{ value: 1 ether }(ETH, quantities, price, deadline, nf, v, r, s);
        vm.stopPrank();

        //node walllet balance assertion
        assertEq(preSale.nodeFundsWallet().balance, expectedNodeWalletFunds, "Node Wallet Funds");
        assertEq(user.balance, expectedUserPayment, "User balance after payment");

        //nft owner assertion
        uint256 tokenId;
        for (uint256 i; i < quantities; ++i) {
            assertEq(nodeNftContract.ownerOf(tokenId), user, "nft owner");
            tokenId += tokenId;
        }
    }

    function testNodePurchaseWithUSDT() external {
        uint256 expectedNodeWalletFunds;
        uint256 prices;

        uint256 deadline = block.timestamp;
        uint256 price = 0;
        uint8 nf = 0;

        //sign
        (uint8 v, bytes32 r, bytes32 s) = _validateSignWithTokenNode(price, nf, USDT, deadline);

        //getting USDT latest price and normalization factor
        uint256 latestPriceETH = tokenRegistryContract.getLatestPrice(IERC20(USDT)).latestPrice;
        uint8 nfETH = tokenRegistryContract.getLatestPrice(IERC20(USDT)).normalizationFactor;

        //calaculating nft purchasing amount
        uint256 quantities = 1;
        prices = preSale.nodeNFTPrice() * quantities;
        expectedNodeWalletFunds = (prices * (10 ** nfETH)) / latestPriceETH;

        //node buying
        vm.startPrank(user);
        USDT.forceApprove(address(preSale), USDT.balanceOf(user));
        preSale.purchaseNodeNFT(USDT, quantities, price, deadline, nf, v, r, s);
        vm.stopPrank();

        //node walllet balance assertion
        assertEq(USDT.balanceOf(preSale.nodeFundsWallet()), expectedNodeWalletFunds, "Node Wallet Funds");

        //nft owner assertion
        uint256 tokenId;
        for (uint256 i; i < quantities; ++i) {
            assertEq(nodeNftContract.ownerOf(tokenId), user, "nft owner");
            tokenId += tokenId;
        }
    }

    function testNodePurchaseWithGEMS() external {
        uint256 expectedNodeWalletFunds;
        uint256 prices;

        uint256 deadline = block.timestamp;
        uint256 price = 1000000000;
        uint8 nf = 22;

        //sign
        (uint8 v, bytes32 r, bytes32 s) = _validateSignWithTokenNode(price, nf, GEMS, deadline);

        //calaculating nft purchasing amount
        uint256 quantities = 1;
        prices = preSale.nodeNFTPrice() * quantities;
        expectedNodeWalletFunds = (prices * (10 ** nf)) / price;

        //node buying
        vm.startPrank(user);
        GEMS.forceApprove(address(preSale), GEMS.balanceOf(user));
        preSale.purchaseNodeNFT(GEMS, quantities, price, deadline, nf, v, r, s);
        vm.stopPrank();

        //node walllet balance assertion
        assertEq(GEMS.balanceOf(preSale.nodeFundsWallet()), expectedNodeWalletFunds, "Node Wallet Funds");

        //nft owner assertion
        uint256 tokenId;
        for (uint256 i; i < quantities; ++i) {
            assertEq(nodeNftContract.ownerOf(tokenId), user, "nft owner");
            tokenId += tokenId;
        }
    }

    function testMinerPurchaseWithETH() external {
        uint256 expectedMinerWalletFunds;
        uint256 expectedUserPayment;
        uint256 prices;

        uint256 deadline = block.timestamp;
        uint256 price = 0;
        uint8 nf = 0;
        bool isInsured = true;

        //sign
        (uint8 v, bytes32 r, bytes32 s) = _validateSignWithToken(price, nf, ETH, deadline, isInsured);

        //getting ETH latest price and normalization factor
        uint256 latestPriceETH = tokenRegistryContract.getLatestPrice(IERC20(ETH)).latestPrice;
        uint8 nfETH = tokenRegistryContract.getLatestPrice(IERC20(ETH)).normalizationFactor;

        //calaculating nft purchasing amount
        uint256[3] memory quantities = [uint(2), uint(2), uint(2)];
        uint256[3] memory minerPrices = minerNFTPrices;
        uint256 quantityLength = quantities.length;

        for (uint256 i; i < quantityLength; ++i) {
            uint256 quantity = quantities[i];

            if (quantity > 0) {
                prices += (minerPrices[i] * quantity);
            }
        }

        expectedMinerWalletFunds = (prices * (10 ** nfETH)) / latestPriceETH;
        expectedUserPayment = user.balance - expectedMinerWalletFunds;

        //miner buying
        vm.startPrank(user);
        preSale.purchaseMinerNFT{ value: 0.24 ether }(ETH, price, deadline, quantities, nf, isInsured, v, r, s);
        vm.stopPrank();

        //user nft balance assertions
        for (uint256 i; i < quantityLength; ++i) {
            uint256 quantity = quantities[i];
            if (quantity > 0) {
                uint256 tokenId = i;
                uint256 userBalance = minerNftContract.balanceOf(user, tokenId);

                assertEq(userBalance, quantity, "user Nfts");
            }
        }
    }

    function testMinerPurchaseWithUSDT() external {
        uint256 expectedMinerWalletFunds;
        uint256 prices;

        uint256 deadline = block.timestamp;
        uint256 price = 0;
        uint8 nf = 0;
        bool isInsured = true;

        //sign
        (uint8 v, bytes32 r, bytes32 s) = _validateSignWithToken(price, nf, USDT, deadline, isInsured);

        //getting USDT latest price and normalization factor
        uint256 latestPriceUSDT = tokenRegistryContract.getLatestPrice(IERC20(USDT)).latestPrice;
        uint8 nfUSDT = tokenRegistryContract.getLatestPrice(IERC20(USDT)).normalizationFactor;

        //calaculating nft purchasing amount
        uint256[3] memory quantities = [uint(1), uint(0), uint(0)];
        uint256[3] memory minerPrices = minerNFTPrices;
        uint256 quantityLength = quantities.length;

        for (uint256 i; i < quantityLength; ++i) {
            uint256 quantity = quantities[i];

            if (quantity > 0) {
                prices += (minerPrices[i] * quantity);
            }
        }

        expectedMinerWalletFunds = (prices * (10 ** nfUSDT)) / latestPriceUSDT;

        //miner buying
        vm.startPrank(user);
        USDT.forceApprove(address(preSale), USDT.balanceOf(user));
        preSale.purchaseMinerNFT(USDT, price, deadline, quantities, nf, true, v, r, s);
        vm.stopPrank();

        //user nft balance assertions
        for (uint256 i; i < quantityLength; ++i) {
            uint256 quantity = quantities[i];
            if (quantity > 0) {
                uint256 tokenId = i;
                uint256 userBalance = minerNftContract.balanceOf(user, tokenId);

                assertEq(userBalance, quantity, "user Nfts");
            }
        }
    }

    function testMinerPurchaseWithGEMS() external {
        uint256 expectedMinerWalletFunds;
        uint256 prices;

        uint256 deadline = block.timestamp;
        uint256 price = 1000000000;
        uint8 nf = 22;
        bool isInsured = true;

        //sign
        (uint8 v, bytes32 r, bytes32 s) = _validateSignWithToken(price, nf, GEMS, deadline, isInsured);

        //calaculating nft purchasing amount
        uint256[3] memory quantities = [uint(1), uint(0), uint(0)];
        uint256[3] memory minerPrices = minerNFTPrices;
        uint256 quantityLength = quantities.length;

        for (uint256 i; i < quantityLength; ++i) {
            uint256 quantity = quantities[i];

            if (quantity > 0) {
                prices += (minerPrices[i] * quantity);
            }
        }

        //GEMS price will come from backend
        expectedMinerWalletFunds = (prices * (10 ** nf)) / price;

        //miner buying
        vm.startPrank(user);
        GEMS.forceApprove(address(preSale), GEMS.balanceOf(user));
        preSale.purchaseMinerNFT(GEMS, price, deadline, quantities, nf, isInsured, v, r, s);
        vm.stopPrank();

        //user nft balance assertions
        for (uint256 i; i < quantityLength; ++i) {
            uint256 quantity = quantities[i];
            if (quantity > 0) {
                uint256 tokenId = i;
                uint256 userBalance = minerNftContract.balanceOf(user, tokenId);

                assertEq(userBalance, quantity, "user Nfts");
            }
        }
    }

    function testMinerDiscountPurchaseWithETH() external {
        uint256 expectedMinerWalletFunds;
        uint256 expectedInsuranceWalletFunds;
        uint256 expectedClaimsFunds;
        uint256 expectedPendingClaims;
        uint256 expectedTotalPercentage;
        uint256 prices;

        uint256 deadline = block.timestamp;
        uint256 discount_percentage_ppm = 100_000;
        uint256 price = 0;
        uint8 nf = 0;
        bool isInsured = true;

        //sign
        (uint8 v, bytes32 r, bytes32 s) = _validateSignWithTokenDiscounted(
            price,
            nf,
            discount_percentage_ppm,
            ETH,
            deadline,
            isInsured
        );

        uint256 leaderPercentageAmount = (percentages[0]) +
            (percentages[1]) +
            (percentages[2]) +
            (percentages[3]) +
            (percentages[4]);

        //leaders previous claims
        uint256[] memory previousLeaderClaims = new uint256[](leaders.length);

        //previous claims funds
        uint256 prevClaimsFunds = address(claimsContract).balance;
        for (uint256 i = 0; i < leaders.length; ++i) {
            previousLeaderClaims[i] = claimsContract.pendingClaims(leaders[i], round, IERC20(ETH));
        }

        //getting ETH latest price and normalization factor
        uint256 latestPriceETH = tokenRegistryContract.getLatestPrice(IERC20(ETH)).latestPrice;
        uint8 nfETH = tokenRegistryContract.getLatestPrice(IERC20(ETH)).normalizationFactor;

        //calaculating nft purchasing amount
        uint256[3] memory quantities = [uint(1), uint(0), uint(0)];
        uint256[3] memory minerPrices = minerNFTPrices;
        uint256 quantityLength = quantities.length;

        for (uint256 i; i < quantityLength; ++i) {
            uint256 quantity = quantities[i];

            if (quantity > 0) {
                prices += (minerPrices[i] * quantity);
            }
        }

        prices = ((prices * (10 ** nfETH)) / latestPriceETH);
        expectedInsuranceWalletFunds = (prices * 50000) / PPM;
        prices = prices - ((prices * discount_percentage_ppm) / PPM);

        //calculating leader claims and funds wallet amount
        uint256 sumPercentage;
        uint256 remainingPercentageAmount;
        for (uint256 j; j < percentages.length; ++j) {
            sumPercentage += percentages[j];
        }

        expectedClaimsFunds = (prices * 250_000) / PPM;
        uint256 sumPercentageAmount = (prices * sumPercentage) / PPM;

        if (sumPercentage < 250_000) {
            remainingPercentageAmount = expectedClaimsFunds - sumPercentageAmount;
        }

        expectedClaimsFunds -= remainingPercentageAmount;
        expectedMinerWalletFunds = prices - expectedClaimsFunds;

        //miner discounted buying
        vm.startPrank(user);
        preSale.purchaseMinerNFTDiscount{ value: 1 ether }(
            ETH,
            price,
            deadline,
            discount_percentage_ppm,
            quantities,
            percentages,
            leaders,
            nf,
            isInsured,
            code,
            v,
            r,
            s
        );
        vm.stopPrank();

        //assertions
        assertEq(preSale.insuranceFundsWallet().balance, expectedInsuranceWalletFunds, "Insurance Wallet Funds");
        assertEq(address(claimsContract).balance, expectedClaimsFunds - prevClaimsFunds, "claims");

        for (uint256 i = 0; i < leaders.length; ++i) {
            expectedPendingClaims = (prices * percentages[i]) / PPM;
            expectedTotalPercentage += percentages[i];
            assertEq(
                claimsContract.pendingClaims(leaders[i], claimsContract.currentWeek(), IERC20(ETH)) -
                    previousLeaderClaims[i],
                expectedPendingClaims,
                "leader fund amount "
            );
        }
        assertEq(expectedTotalPercentage, leaderPercentageAmount, "leader percentage contract");

        //user nft balance assertions
        for (uint256 i; i < quantityLength; ++i) {
            uint256 quantity = quantities[i];
            if (quantity > 0) {
                uint256 tokenId = i;
                uint256 userBalance = minerNftContract.balanceOf(user, tokenId);

                assertEq(userBalance, quantity, "user Nfts");
            }
        }
    }

    function testMinerDiscountPurchaseWithUSDT() external {
        uint256 expectedMinerWalletFunds;
        uint256 expectedInsuranceWalletFunds;
        uint256 expectedClaimsFunds;
        uint256 expectedPendingClaims;
        uint256 expectedTotalPercentage;
        uint256 prices;

        uint256 deadline = block.timestamp;
        uint256 discount_percentage_ppm = 100_000;
        uint256 price = 0;
        uint8 nf = 0;
        bool isInsured = true;

        //sign
        (uint8 v, bytes32 r, bytes32 s) = _validateSignWithTokenDiscounted(
            price,
            nf,
            discount_percentage_ppm,
            USDT,
            deadline,
            isInsured
        );

        uint256 leaderPercentageAmount = (percentages[0]) +
            (percentages[1]) +
            (percentages[2]) +
            (percentages[3]) +
            (percentages[4]);

        //leaders previous claims
        uint256[] memory previousLeaderClaims = new uint256[](leaders.length);

        //previous claims funds
        uint256 prevClaimsFunds = USDT.balanceOf(address(claimsContract)) + 1;
        for (uint256 i = 0; i < leaders.length; ++i) {
            previousLeaderClaims[i] = claimsContract.pendingClaims(leaders[i], round, IERC20(USDT));
        }

        //getting USDT latest price and normalization factor
        uint256 latestPriceUSDT = tokenRegistryContract.getLatestPrice(IERC20(USDT)).latestPrice;
        uint8 nfUSDT = tokenRegistryContract.getLatestPrice(IERC20(USDT)).normalizationFactor;

        //calaculating nft purchasing amount
        uint256[3] memory quantities = [uint(1), uint(0), uint(0)];
        uint256[3] memory minerPrices = minerNFTPrices;
        uint256 quantityLength = quantities.length;

        for (uint256 i; i < quantityLength; ++i) {
            uint256 quantity = quantities[i];

            if (quantity > 0) {
                prices += (minerPrices[i] * quantity);
            }
        }

        prices = ((prices * (10 ** nfUSDT)) / latestPriceUSDT);
        expectedInsuranceWalletFunds = (prices * 50000) / PPM;

        prices = prices - ((prices * discount_percentage_ppm) / PPM);

        //calculating leader claims and funds wallet amount
        uint256 sumPercentage;
        uint256 remainingPercentageAmount;
        for (uint256 j; j < percentages.length; ++j) {
            sumPercentage += percentages[j];
        }

        expectedClaimsFunds = (prices * 250_000) / PPM;
        uint256 sumPercentageAmount = (prices * sumPercentage) / PPM;

        if (sumPercentage < 250_000) {
            remainingPercentageAmount = expectedClaimsFunds - sumPercentageAmount;
        }

        expectedClaimsFunds -= remainingPercentageAmount;
        expectedMinerWalletFunds = prices - expectedClaimsFunds;

        //miner discounted buying
        vm.startPrank(user);
        USDT.forceApprove(address(preSale), USDT.balanceOf(user));
        preSale.purchaseMinerNFTDiscount(
            USDT,
            price,
            deadline,
            discount_percentage_ppm,
            quantities,
            percentages,
            leaders,
            nf,
            true,
            code,
            v,
            r,
            s
        );
        vm.stopPrank();

        // //assertions
        assertEq(
            USDT.balanceOf(preSale.insuranceFundsWallet()),
            expectedInsuranceWalletFunds,
            "Insurance Wallet Funds"
        );
        assertEq(USDT.balanceOf(address(claimsContract)), expectedClaimsFunds - prevClaimsFunds, "claims");

        for (uint256 i = 0; i < leaders.length; ++i) {
            expectedPendingClaims = (prices * percentages[i]) / PPM;
            expectedTotalPercentage += percentages[i];
            assertEq(
                claimsContract.pendingClaims(leaders[i], claimsContract.currentWeek(), IERC20(USDT)) -
                    previousLeaderClaims[i],
                expectedPendingClaims,
                "leader fund amount "
            );
        }
        assertEq(expectedTotalPercentage, leaderPercentageAmount, "leader percentage contract");

        //user nft balance assertions
        for (uint256 i; i < quantityLength; ++i) {
            uint256 quantity = quantities[i];
            if (quantity > 0) {
                uint256 tokenId = i;
                uint256 userBalance = minerNftContract.balanceOf(user, tokenId);

                assertEq(userBalance, quantity, "user Nfts");
            }
        }
    }

    function testMinerDiscountPurchaseWithGEMS() external {
        uint256 expectedMinerWalletFunds;
        uint256 expectedInsuranceWalletFunds;
        uint256 expectedClaimsFunds;
        uint256 expectedPendingClaims;
        uint256 expectedTotalPercentage;
        uint256 prices;

        uint256 deadline = block.timestamp;
        uint256 discount_percentage_ppm = 100_000;
        uint256 price = 1000000000;
        uint8 nf = 22;
        bool isInsured = true;

        //sign
        (uint8 v, bytes32 r, bytes32 s) = _validateSignWithTokenDiscounted(
            price,
            nf,
            discount_percentage_ppm,
            GEMS,
            deadline,
            isInsured
        );

        uint256 leaderPercentageAmount = (percentages[0]) +
            (percentages[1]) +
            (percentages[2]) +
            (percentages[3]) +
            (percentages[4]);

        //leaders previous claims
        uint256[] memory previousLeaderClaims = new uint256[](leaders.length);

        //previous claims funds
        uint256 prevClaimsFunds = GEMS.balanceOf(address(claimsContract));
        for (uint256 i = 0; i < leaders.length; ++i) {
            previousLeaderClaims[i] = claimsContract.pendingClaims(leaders[i], round, IERC20(GEMS));
        }

        //calaculating nft purchasing amount
        uint256[3] memory quantities = [uint(1), uint(0), uint(0)];
        uint256[3] memory minerPrices = minerNFTPrices;
        uint256 quantityLength = quantities.length;

        for (uint256 i; i < quantityLength; ++i) {
            uint256 quantity = quantities[i];

            if (quantity > 0) {
                prices += (minerPrices[i] * quantity);
            }
        }

        //GEMS price will come from backend
        prices = ((prices * (10 ** nf)) / price);
        expectedInsuranceWalletFunds = (prices * 50000) / PPM;
        prices = prices - ((prices * discount_percentage_ppm) / PPM);

        //calculating leader claims and funds wallet amount
        uint256 sumPercentage;
        uint256 remainingPercentageAmount;
        for (uint256 j; j < percentages.length; ++j) {
            sumPercentage += percentages[j];
        }

        expectedClaimsFunds = (prices * 250_000) / PPM;
        uint256 sumPercentageAmount = (prices * sumPercentage) / PPM;

        if (sumPercentage < 250_000) {
            remainingPercentageAmount = expectedClaimsFunds - sumPercentageAmount;
        }

        expectedClaimsFunds -= remainingPercentageAmount;
        expectedMinerWalletFunds = prices - expectedClaimsFunds;

        //miner discounted buying
        vm.startPrank(user);
        GEMS.forceApprove(address(preSale), GEMS.balanceOf(user));
        preSale.purchaseMinerNFTDiscount(
            GEMS,
            price,
            deadline,
            discount_percentage_ppm,
            quantities,
            percentages,
            leaders,
            nf,
            isInsured,
            code,
            v,
            r,
            s
        );
        vm.stopPrank();

        //assertions
        assertEq(
            GEMS.balanceOf(preSale.insuranceFundsWallet()),
            expectedInsuranceWalletFunds,
            "Insurance Wallet Funds"
        );
        assertEq(GEMS.balanceOf(address(claimsContract)), expectedClaimsFunds - prevClaimsFunds, "claims");

        for (uint256 i = 0; i < leaders.length; ++i) {
            expectedPendingClaims = (prices * percentages[i]) / PPM;
            expectedTotalPercentage += percentages[i];
            assertEq(
                claimsContract.pendingClaims(leaders[i], claimsContract.currentWeek(), IERC20(GEMS)),
                expectedPendingClaims,
                "leader fund amount "
            );
        }
        assertEq(expectedTotalPercentage, leaderPercentageAmount, "leader percentage contract");

        //user nft balance assertions
        for (uint256 i; i < quantityLength; ++i) {
            uint256 quantity = quantities[i];
            if (quantity > 0) {
                uint256 tokenId = i;
                uint256 userBalance = minerNftContract.balanceOf(user, tokenId);

                assertEq(userBalance, quantity, "user Nfts");
            }
        }
    }

    function _validateSignWithTokenNode(
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

    function _validateSignWithToken(
        uint256 referenceTokenPrice,
        uint256 normalizationFactor,
        IERC20 token,
        uint256 deadline,
        bool isInsured
    ) private returns (uint8, bytes32, bytes32) {
        vm.startPrank(signer);
        bytes32 msgHash = (
            keccak256(
                abi.encodePacked(
                    user,
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
