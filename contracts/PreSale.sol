// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import { SafeERC20, IERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { ECDSA } from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import { MessageHashUtils } from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import { ReentrancyGuardTransient } from "@openzeppelin/contracts/utils/ReentrancyGuardTransient.sol";
import { Ownable2Step, Ownable } from "@openzeppelin/contracts/access/Ownable2Step.sol";

import { IClaims } from "./interfaces/IClaims.sol";
import { ITokenRegistry } from "./interfaces/ITokenRegistry.sol";
import { IMinerNft } from "./interfaces/IMinerNft.sol";
import { INodeNft } from "./interfaces/INodeNft.sol";

import { PPM, ZeroAddress, IdenticalValue, ArrayLengthMismatch, InvalidSignature, InvalidData, TokenInfo, ZeroValue } from "./utils/Common.sol";

/// @title PreSale contract
/// @notice Implements presale of the node and miner nfts
/// @dev The presale contract allows you to purchase node nft and miner nfts
contract PreSale is Ownable2Step, ReentrancyGuardTransient {
    using SafeERC20 for IERC20;

    /// @dev The constant value helps in calculating amount
    uint256 private constant CLAIMS_PERCENTAGE_PPM = 250_000;

    /// @dev The constant value helps in calculating values
    uint256 private constant DISCOUNT_PERCENTAGE_PPM = 500_000;

    /// @dev The constant value helps in calculating values
    uint256 private constant PRICE_ACCRETION_PERENTAGE_PPM = 50_000;

    /// @dev The constant value of one million in dollars
    uint256 private constant ONE_MILLION_DOLLAR = 1_000_000e6;

    /// @dev The max length of the leaders array
    uint256 private constant LEADERS_LENGTH = 5;

    /// @notice The maximum amount of money a project hopes to raise
    uint256 public constant MAX_CAP = 40_000_000e6;

    /// @notice The address of claims contract
    IClaims public immutable claimsContract;

    /// @notice The address of the token registry contract
    ITokenRegistry public tokenRegistry;

    /// @notice The address of the miner nft contract
    IMinerNft public immutable minerNft;

    /// @notice The address of the node nft contract
    INodeNft public immutable nodeNft;

    /// @notice The address of the GEMS contract
    IERC20 public immutable GEMS;

    /// @notice The address of the USDT contract
    IERC20 public immutable USDT;

    /// @notice The total purchases upto 1 million usd, it will reset after every million cap increased
    uint256 public accretionThreshold;

    /// @notice The price of the miner nft
    uint256 public nodeNFTPrice;

    /// @notice The total usd raised
    uint256 public totalRaised;

    /// @notice That buyEnabled or not
    bool public buyEnabled = true;

    /// @notice The address of the signer wallet
    address public signerWallet;

    /// @notice The address of the node funds wallet
    address public nodeFundsWallet;

    /// @notice The address of the miner funds wallet
    address public minerFundsWallet;

    /// @notice The prices of the node nfts
    uint256[3] public minerNFTPrices;

    /// @notice Gives info about address's permission
    mapping(address => bool) public blacklistAddress;

    /// @dev Emitted when address of signer is updated
    event SignerUpdated(address oldSigner, address newSigner);

    /// @dev Emitted when address of node funds wallet is updated
    event NodeFundsWalletUpdated(address oldNodeFundsWallet, address newNodeFundsWallet);

    /// @dev Emitted when address of miner funds wallet is updated
    event MinerFundsWalletUpdated(address oldMinerFundsWallet, address newMinerFundsWallet);

    /// @dev Emitted when blacklist access of address is updated
    event BlacklistUpdated(address which, bool accessNow);

    /// @dev Emitted when buying access changes
    event BuyEnableUpdated(bool oldAccess, bool newAccess);

    /// @dev Emitted when node nft price is updated
    event NodeNftPriceUpdated(uint256 oldPrice, uint256 newPrice);

    /// @dev Emitted when node nft is purchased
    event NodeNftPurchased(uint256 tokenPrice, address indexed by, uint256 amountPurchased, uint256 quantity);

    /// @dev Emitted when miner nft is purchased
    event MinerNftPurchased(
        uint256 tokenPrice,
        address indexed by,
        uint256[3] minerPrices,
        uint256[3] quantities,
        uint256 amountPurchased
    );

    /// @dev Emitted when miner nft is purchased on discounted price
    event MinerNftPurchasedDiscounted(
        uint256 tokenPrice,
        address indexed by,
        uint256[3] minerPrices,
        uint256[3] quantities,
        string code,
        uint256 amountPurchased,
        address[] leaders,
        uint256[] percentages
    );

    // @dev Emitted when address of  token regitry contract is updated
    event TokenRegistryUpdated(ITokenRegistry oldTokenRegistry, ITokenRegistry newTokenRegistry);

    /// @notice Thrown when address is blacklisted
    error Blacklisted();

    /// @notice Thrown when buy is disabled
    error BuyNotEnabled();

    /// @notice Thrown when sign deadline is expired
    error DeadlineExpired();

    /// @notice Thrown when caller is not claims contract
    error OnlyClaims();

    /// @notice Thrown when MAX_CAP is reached
    error MaxCapReached();

    /// @notice Thrown if the sum of agents percentage is greater than required
    error InvalidPercentage();

    /// @notice Thrown when array length of leaders are greater than required
    error InvalidArrayLength();

    /// @notice Thrown when caller does not hold nft id
    error CallerNotOwner();

    /// @dev Restricts when updating wallet/contract address with zero address
    modifier checkAddressZero(address which) {
        _checkAddressZero(which);
        _;
    }

    /// @dev Checks buyEnabled and user not blacklisted, if yes then reverts
    modifier canBuy() {
        _canBuy();
        _;
    }

    /// @dev Constructor
    /// @param nodeFundsWalletAddress The address of node funds wallet
    /// @param minerFundsWalletAddress The address of node funds wallet
    /// @param signerAddress The address of signer wallet
    /// @param owner The address of owner wallet
    /// @param gemsAddress The address gems contract
    /// @param usdtAddress The address of usdt contract
    /// @param claimsAddress The address of claim contract
    /// @param minerNftAddress The address of miner nft contract
    /// @param nodeNftAddress The address of miner nft contract
    /// @param tokenRegistryAddress The address of token registry contract
    /// @param nodeNftPriceInit The price of minor nft
    /// @param minerNftPricesInit The prices of node nfts
    constructor(
        address nodeFundsWalletAddress,
        address minerFundsWalletAddress,
        address signerAddress,
        address owner,
        IERC20 gemsAddress,
        IERC20 usdtAddress,
        IClaims claimsAddress,
        IMinerNft minerNftAddress,
        INodeNft nodeNftAddress,
        ITokenRegistry tokenRegistryAddress,
        uint256 nodeNftPriceInit,
        uint256[3] memory minerNftPricesInit
    )
        Ownable(owner)
        checkAddressZero(nodeFundsWalletAddress)
        checkAddressZero(minerFundsWalletAddress)
        checkAddressZero(signerAddress)
        checkAddressZero(address(gemsAddress))
        checkAddressZero(address(usdtAddress))
        checkAddressZero(address(claimsAddress))
        checkAddressZero(address(minerNftAddress))
        checkAddressZero(address(nodeNftAddress))
        checkAddressZero(address(tokenRegistryAddress))
    {
        if (nodeNftPriceInit == 0) {
            revert ZeroValue();
        }

        for (uint256 i; i < minerNftPricesInit.length; ++i) {
            if (minerNftPricesInit[i] == 0) {
                revert ZeroValue();
            }
        }

        nodeFundsWallet = nodeFundsWalletAddress;
        minerFundsWallet = minerFundsWalletAddress;
        signerWallet = signerAddress;
        GEMS = gemsAddress;
        USDT = usdtAddress;
        claimsContract = claimsAddress;
        minerNft = minerNftAddress;
        nodeNft = nodeNftAddress;
        tokenRegistry = tokenRegistryAddress;
        nodeNFTPrice = nodeNftPriceInit;
        minerNFTPrices = minerNftPricesInit;
    }

    /// @notice Purchases node nfts with GEMS
    /// @param quantity The amounts of node nfts to purchase
    /// @param referenceTokenPrice The current price of GEMS in 10 decimals
    /// @param deadline The deadline is validity of the signature
    /// @param referenceNormalizationFactor The normalization factor
    /// @param v The `v` signature parameter
    /// @param r The `r` signature parameter
    /// @param s The `s` signature parameter
    function purchaseNodeNFT(
        uint256 quantity,
        uint256 referenceTokenPrice,
        uint256 deadline,
        uint8 referenceNormalizationFactor,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external canBuy nonReentrant {
        if (block.timestamp > deadline) {
            revert DeadlineExpired();
        }

        if (referenceTokenPrice == 0 || referenceNormalizationFactor == 0) {
            revert ZeroValue();
        }
        // The input must have been signed by the presale signer
        _verifySignature(
            keccak256(abi.encodePacked(msg.sender, referenceNormalizationFactor, referenceTokenPrice, deadline, GEMS)),
            v,
            r,
            s
        );
        uint256 purchaseAmount = (quantity * nodeNFTPrice * (10 ** referenceNormalizationFactor)) / referenceTokenPrice;
        _checkZeroValue(purchaseAmount);
        GEMS.safeTransferFrom(msg.sender, nodeFundsWallet, purchaseAmount);
        nodeNft.mint(msg.sender, quantity);

        emit NodeNftPurchased({
            tokenPrice: referenceTokenPrice,
            by: msg.sender,
            amountPurchased: purchaseAmount,
            quantity: quantity
        });
    }

    /// @notice Purchases miner nft with USDT
    /// @param nodeNftId The node nft id that user holds
    /// @param quantities The amount of each miner nft that user will purchase
    function purchaseMinerNFT(uint256 nodeNftId, uint256[3] calldata quantities) external canBuy nonReentrant {
        uint256[3] memory minerPrices = minerNFTPrices;
        (uint256 purchaseAmount, uint256 latestPrice) = _processPurchase(nodeNftId, quantities, false);
        _checkZeroValue(purchaseAmount);
        USDT.safeTransferFrom(msg.sender, minerFundsWallet, purchaseAmount);

        emit MinerNftPurchased({
            tokenPrice: latestPrice,
            by: msg.sender,
            minerPrices: minerPrices,
            quantities: quantities,
            amountPurchased: purchaseAmount
        });
    }

    /// @notice Purchases miner nft on discounted price
    /// @param nodeNftId The node nft id that user holds
    /// @param deadline The deadline is validity of the signature
    /// @param quantities The amount of each miner nft that user will purchase
    /// @param percentages The leader's percentages
    /// @param leaders The addresses of the leaders
    /// @param code The code is used to verify signature of the user
    /// @param v The `v` signature parameter
    /// @param r The `r` signature parameter
    /// @param s The `s` signature parameter
    function purchaseMinerNFTDiscount(
        uint256 nodeNftId,
        uint256 deadline,
        uint256[3] calldata quantities,
        uint256[] calldata percentages,
        address[] calldata leaders,
        string memory code,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external canBuy nonReentrant {
        // The input must have been signed by the presale signer
        _verifySignature(keccak256(abi.encodePacked(msg.sender, code, percentages, leaders, deadline, USDT)), v, r, s);

        if (block.timestamp > deadline) {
            revert DeadlineExpired();
        }

        uint256[3] memory minerPrices = minerNFTPrices;
        (uint256 purchaseAmount, uint256 latestPrice) = _processPurchase(nodeNftId, quantities, true);
        _transferAndUpdateCommissions(purchaseAmount, leaders, percentages);

        emit MinerNftPurchasedDiscounted({
            tokenPrice: latestPrice,
            by: msg.sender,
            minerPrices: minerPrices,
            quantities: quantities,
            code: code,
            amountPurchased: purchaseAmount,
            leaders: leaders,
            percentages: percentages
        });
    }

    /// @notice Changes access of buying
    /// @param enabled The decision about buying
    function enableBuy(bool enabled) external onlyOwner {
        if (buyEnabled == enabled) {
            revert IdenticalValue();
        }

        emit BuyEnableUpdated({ oldAccess: buyEnabled, newAccess: enabled });

        buyEnabled = enabled;
    }

    /// @notice Changes signer wallet address
    /// @param newSigner The address of the new signer wallet
    function changeSigner(address newSigner) external checkAddressZero(newSigner) onlyOwner {
        address oldSigner = signerWallet;

        if (oldSigner == newSigner) {
            revert IdenticalValue();
        }

        emit SignerUpdated({ oldSigner: oldSigner, newSigner: newSigner });

        signerWallet = newSigner;
    }

    /// @notice Changes node funds wallet address
    /// @param newNodeFundsWallet The address of the new funds wallet
    function updateNodeFundsWallet(address newNodeFundsWallet) external checkAddressZero(newNodeFundsWallet) onlyOwner {
        address oldNodeFundsWallet = nodeFundsWallet;

        if (oldNodeFundsWallet == newNodeFundsWallet) {
            revert IdenticalValue();
        }

        emit NodeFundsWalletUpdated({ oldNodeFundsWallet: oldNodeFundsWallet, newNodeFundsWallet: newNodeFundsWallet });

        nodeFundsWallet = newNodeFundsWallet;
    }

    /// @notice Changes miner funds wallet address
    /// @param newMinerFundsWallet The address of the new funds wallet
    function updateMinerFundsWallet(
        address newMinerFundsWallet
    ) external checkAddressZero(newMinerFundsWallet) onlyOwner {
        address oldMinerFundsWallet = minerFundsWallet;

        if (oldMinerFundsWallet == newMinerFundsWallet) {
            revert IdenticalValue();
        }

        emit MinerFundsWalletUpdated({
            oldMinerFundsWallet: oldMinerFundsWallet,
            newMinerFundsWallet: newMinerFundsWallet
        });

        minerFundsWallet = newMinerFundsWallet;
    }

    /// @notice Changes the access of any address in contract interaction
    /// @param which The address for which access is updated
    /// @param access The access decision of `which` address
    function updateBlackListedUser(address which, bool access) external checkAddressZero(which) onlyOwner {
        bool oldAccess = blacklistAddress[which];

        if (oldAccess == access) {
            revert IdenticalValue();
        }

        emit BlacklistUpdated({ which: which, accessNow: access });

        blacklistAddress[which] = access;
    }

    /// @notice Changes token registry contract address
    /// @param newTokenRegistry The address of the new token registry contract
    function updateTokenRegistry(
        ITokenRegistry newTokenRegistry
    ) external checkAddressZero(address(newTokenRegistry)) onlyOwner {
        ITokenRegistry oldTokenRegistry = tokenRegistry;

        if (oldTokenRegistry == newTokenRegistry) {
            revert IdenticalValue();
        }

        emit TokenRegistryUpdated({ oldTokenRegistry: oldTokenRegistry, newTokenRegistry: newTokenRegistry });

        tokenRegistry = newTokenRegistry;
    }

    /// @notice Changes the node nft prices
    /// @param newPrice The new price of node nft
    function updateNodeNftPrice(uint256 newPrice) external onlyOwner {
        uint256 oldPrice = nodeNFTPrice;

        if (newPrice == oldPrice) {
            revert IdenticalValue();
        }

        if (newPrice == 0) {
            revert ZeroValue();
        }

        emit NodeNftPriceUpdated({ oldPrice: oldPrice, newPrice: newPrice });

        nodeNFTPrice = newPrice;
    }

    /// @dev Processes miner nft purchase
    function _processPurchase(
        uint256 nodeNftId,
        uint256[3] calldata quantities,
        bool isDiscounted
    ) private returns (uint256, uint256) {
        if (nodeNft.ownerOf(nodeNftId) != msg.sender) {
            revert CallerNotOwner();
        }

        TokenInfo memory tokenInfo = tokenRegistry.getLatestPrice(USDT);

        if (tokenInfo.latestPrice == 0 || tokenInfo.normalizationFactor == 0) {
            revert ZeroValue();
        }

        uint256 prices;
        uint256 quantityLength = quantities.length;

        for (uint256 i; i < quantityLength; ++i) {
            uint256 quantity = quantities[i];

            if (quantity > 0) {
                prices += (minerNFTPrices[i] * quantity);
                minerNft.mint(msg.sender, i, quantity);
            }
        }

        _checkZeroValue(prices);

        if (isDiscounted) {
            prices = (prices * DISCOUNT_PERCENTAGE_PPM) / PPM;
        }

        totalRaised += prices;

        if (totalRaised >= MAX_CAP) {
            revert MaxCapReached();
        }

        uint256 raised = accretionThreshold += prices;

        if (raised >= ONE_MILLION_DOLLAR) {
            uint256 repetitions = raised / ONE_MILLION_DOLLAR;
            accretionThreshold -= ONE_MILLION_DOLLAR * repetitions;

            for (uint256 i; i < quantityLength; ++i) {
                for (uint256 j; j < repetitions; ++j) {
                    minerNFTPrices[i] += (minerNFTPrices[i] * PRICE_ACCRETION_PERENTAGE_PPM) / PPM;
                }
            }
        }

        return ((prices * (10 ** tokenInfo.normalizationFactor)) / tokenInfo.latestPrice, tokenInfo.latestPrice);
    }

    /// @dev Checks value, if zero then reverts
    function _checkZeroValue(uint256 value) private pure {
        if (value == 0) {
            revert ZeroValue();
        }
    }

    /// @dev Verifies the address that signed a hashed message (`hash`) with `signature`
    function _verifySignature(bytes32 encodedMessageHash, uint8 v, bytes32 r, bytes32 s) private view {
        if (signerWallet != ECDSA.recover(MessageHashUtils.toEthSignedMessageHash(encodedMessageHash), v, r, s)) {
            revert InvalidSignature();
        }
    }

    /// @dev Checks zero address, if zero then reverts
    /// @param which The `which` address to check for zero address
    function _checkAddressZero(address which) private pure {
        if (which == address(0)) {
            revert ZeroAddress();
        }
    }

    /// @dev Checks buyEnabled, user not blacklisted , if yes then reverts
    function _canBuy() private view {
        if (!buyEnabled) {
            revert BuyNotEnabled();
        }

        if (blacklistAddress[msg.sender]) {
            revert Blacklisted();
        }
    }

    /// @dev Calculates, transfers and update commissions
    function _transferAndUpdateCommissions(
        uint256 amount,
        address[] memory leaders,
        uint256[] memory percentages
    ) private {
        _checkZeroValue(amount);

        uint256 toLength = leaders.length;
        uint256 sumPercentage;

        if (toLength == 0) {
            revert InvalidData();
        }

        if (toLength > LEADERS_LENGTH) {
            revert InvalidArrayLength();
        }

        if (toLength != percentages.length) {
            revert ArrayLengthMismatch();
        }

        uint256[] memory claims = new uint256[](toLength);

        for (uint256 i; i < toLength; ++i) {
            uint256 percentage = percentages[i];
            sumPercentage += percentage;
            claims[i] = (amount * percentage) / PPM;
        }

        if (sumPercentage == 0) {
            revert ZeroValue();
        }

        if (sumPercentage > CLAIMS_PERCENTAGE_PPM) {
            revert InvalidPercentage();
        }

        uint256 equivalence = (amount * sumPercentage) / PPM;

        if (sumPercentage < CLAIMS_PERCENTAGE_PPM) {
            amount -= equivalence;
        }

        USDT.safeTransferFrom(msg.sender, minerFundsWallet, amount);
        USDT.safeTransferFrom(msg.sender, address(claimsContract), equivalence);

        claimsContract.addClaimInfo(leaders, claims);
    }
}
