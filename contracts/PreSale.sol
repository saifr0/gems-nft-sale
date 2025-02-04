// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import { SafeERC20, IERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { ECDSA } from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import { Address } from "@openzeppelin/contracts/utils/Address.sol";
import { MessageHashUtils } from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import { ReentrancyGuardTransient } from "@openzeppelin/contracts/utils/ReentrancyGuardTransient.sol";
import { Ownable2Step, Ownable } from "@openzeppelin/contracts/access/Ownable2Step.sol";

import { IClaims, ClaimInfo } from "./interfaces/IClaims.sol";
import { ITokenRegistry } from "./interfaces/ITokenRegistry.sol";
import { IMinerNft } from "./interfaces/IMinerNft.sol";
import { INodeNft } from "./interfaces/INodeNft.sol";

import { PPM, ETH, ZeroAddress, IdenticalValue, ArrayLengthMismatch, InvalidSignature, InvalidData, TokenInfo } from "./utils/Common.sol";

/// @title PreSale contract
/// @notice Implements presale of the node and miner nfts
/// @dev The presale contract allows you to purchase node nft and miner nfts
contract PreSale is Ownable2Step, ReentrancyGuardTransient {
    using SafeERC20 for IERC20;
    using Address for address payable;

    /// @dev To achieve return value of required decimals during calculation
    uint256 private constant NORMALIZATION_FACTOR = 1e30;

    /// @dev The constant value helps in calculating project amount
    uint256 private constant PROJECT_PERCENTAGE_PPM = 630_000;

    /// @dev The constant value helps in calculating amount
    uint256 private constant CLAIMS_PERCENTAGE_PPM = 250_000;

    /// @dev The constant value helps in calculating values
    uint256 private constant DISCOUNT_PERCENTAGE_PPM = 500_000;

    /// @dev The constant value of one million in dollars
    uint256 private constant ONE_MILLION_DOLLAR = 1_000_000e6;

    /// @dev The constant value helps in calculating platform amount
    uint256 private constant PLATFORM_PERCENTAGE_PPM = 100_000;

    /// @dev The constant value helps in calculating burn amount
    uint256 private constant BURN_PERCENTAGE_PPM = 20_000;

    /// @dev The max length of the leaders array
    uint256 private constant LEADERS_LENGTH = 5;

    /// @notice The maximum amount of money a project hopes to raise in order to proceed with the project
    uint256 public constant MAX_CAP = 40_000_000e6;

    /// @notice The total usd raisedUsd
    uint256 public totalRaised;

    /// @notice The total purchases upto 1 million usd, it will reset after every million cap increased
    uint256 public accretionThreshold;

    /// @notice The address of claims contract
    IClaims public immutable claimsContract;

    /// @notice The address of the miner nft contract
    IMinerNft public immutable minerNft;

    /// @notice The address of the node nft contract
    INodeNft public immutable nodeNft;

    /// @notice That buyEnabled or not
    bool public buyEnabled = true;

    /// @notice The address of the token registry contract
    ITokenRegistry public tokenRegistry;

    /// @notice The address of the signer wallet
    address public signerWallet;

    /// @notice The address of the node funds wallet
    address public nodeFundsWallet;

    /// @notice The address of the miner funds wallet
    address public minerFundsWallet;

    /// @notice The address of the project wallet
    address public projectWallet;

    /// @notice The address of the platform wallet
    address public platformWallet;

    /// @notice The address of the burn wallet
    address public burnWallet;

    /// @notice The price of the miner nft
    uint256 public nodeNFTPrice;

    /// @notice The value helps in calculating new price of miner
    uint256 public priceAccretionPercentagePPM;

    /// @notice The prices of the node nfts
    uint256[3] public minerNFTPrices;

    /// @notice Gives info about address's permission
    mapping(address => bool) public blacklistAddress;

    /// @notice Gives access info of the given token
    mapping(IERC20 => bool) public allowedTokens;

    /// @dev Emitted when address of signer is updated
    event SignerUpdated(address oldSigner, address newSigner);

    /// @dev Emitted when address of node funds wallet is updated
    event NodeFundsWalletUpdated(address oldNodeFundsWallet, address newNodeFundsWallet);

    /// @dev Emitted when address of miner funds wallet is updated
    event MinerFundsWalletUpdated(address oldMinerFundsWallet, address newMinerFundsWallet);

    /// @dev Emitted when address of platform wallet is updated
    event PlatformWalletUpdated(address oldPlatformWallet, address newPlatformWallet);

    /// @dev Emitted when address of project wallet is updated
    event ProjectWalletUpdated(address oldProjectWallet, address newProjectWallet);

    /// @dev Emitted when address of burn wallet is updated
    event BurnWalletUpdated(address oldBurnWallet, address newBurnWallet);

    /// @dev Emitted when blacklist access of address is updated
    event BlacklistUpdated(address which, bool accessNow);

    /// @dev Emitted when buying access changes
    event BuyEnableUpdated(bool oldAccess, bool newAccess);

    /// @dev Emitted when token's access is updated
    event AllowedTokenUpdated(IERC20 token, bool status);

    // @dev Emitted when address of  token regitry contract is updated
    event TokenRegistryUpdated(ITokenRegistry oldTokenRegistry, ITokenRegistry newTokenRegistry);

    // @dev Emitted when miner price accretion percentage is updated
    event PriceAccretionPercentageUpdated(uint256 oldPriceAccretionPercent, uint256 newPriceAccretionPercent);

    /// @dev Emitted when node nft price is updated
    event NodeNftPriceUpdated(uint256 oldPrice, uint256 newPrice);

    /// @dev Emitted when node nft is purchased
    event NodeNftPurchased(IERC20 token, uint256 tokenPrice, address by, uint256 amountPurchased, uint256 quantity);

    /// @dev Emitted when miner nft is purchased
    event MinerNftPurchased(
        IERC20 token,
        uint256 tokenPrice,
        address by,
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

    /// @notice Thrown when address is blacklisted
    error Blacklisted();

    /// @notice Thrown when buy is disabled
    error BuyNotEnabled();

    /// @notice Thrown when sign deadline is expired
    error DeadlineExpired();

    /// @notice Thrown when value to transfer is zero
    error ZeroValue();

    /// @notice Thrown when caller is not claims contract
    error OnlyClaims();

    /// @notice Thrown when MAX_CAP is reached
    error MaxCapReached();

    /// @notice Thrown when both price feed and reference price are non zero
    error CodeSyncIssue();

    /// @notice Thrown if the sum of agents percentage is greater than required
    error InvalidPercentage();

    /// @notice Thrown when array length of leaders are greater than required
    error InvalidArrayLength();

    /// @notice Thrown when token is not allowed to use for purchases
    error TokenNotAllowed();

    /// @dev Restricts when updating wallet/contract address with zero address
    modifier checkAddressZero(address which) {
        _checkAddressZero(which);
        _;
    }

    /// @dev Checks buyEnabled,token allowed, user not blacklisted and time less than deadline, if not then reverts
    modifier canBuy(IERC20 token, uint256 deadline) {
        _canBuy(token, deadline);
        _;
    }

    /// @dev Constructor
    /// @param nodeFundsWalletAddress The address of node funds wallet
    /// @param minerFundsWalletAddress The address of miner funds wallet
    /// @param projectWalletAddress The address of project wallet
    /// @param platformWalletAddress The address of platform wallet
    /// @param burnWalletAddress The address of burn wallet
    /// @param signerAddress The address of signer wallet
    /// @param owner The address of owner wallet
    /// @param claimsAddress The address of claim contract
    /// @param minerNftAddress The address of miner nft contract
    /// @param nodeNftAddress The address of miner nft contract
    /// @param tokenRegistryAddress The address of token registry contract
    /// @param nodeNftPriceInit The price of minor nft
    /// @param priceAccretionPercentagePPMInit The price accretion percentage value, it can be zero
    /// @param minerNftPricesInit The prices of node nfts
    constructor(
        address nodeFundsWalletAddress,
        address minerFundsWalletAddress,
        address projectWalletAddress,
        address platformWalletAddress,
        address burnWalletAddress,
        address signerAddress,
        address owner,
        IClaims claimsAddress,
        IMinerNft minerNftAddress,
        INodeNft nodeNftAddress,
        ITokenRegistry tokenRegistryAddress,
        uint256 nodeNftPriceInit,
        uint256 priceAccretionPercentagePPMInit,
        uint256[3] memory minerNftPricesInit
    )
        Ownable(owner)
        checkAddressZero(nodeFundsWalletAddress)
        checkAddressZero(minerFundsWalletAddress)
        checkAddressZero(projectWalletAddress)
        checkAddressZero(platformWalletAddress)
        checkAddressZero(burnWalletAddress)
        checkAddressZero(signerAddress)
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
        projectWallet = projectWalletAddress;
        platformWallet = platformWalletAddress;
        burnWallet = burnWalletAddress;
        signerWallet = signerAddress;
        claimsContract = claimsAddress;
        minerNft = minerNftAddress;
        nodeNft = nodeNftAddress;
        tokenRegistry = tokenRegistryAddress;
        nodeNFTPrice = nodeNftPriceInit;
        priceAccretionPercentagePPM = priceAccretionPercentagePPMInit;
        minerNFTPrices = minerNftPricesInit;
    }

    /// @notice Purchases node nfts with token
    /// @param token The token used for purchasing
    /// @param quantity The amounts of node nfts to purchase
    /// @param referenceTokenPrice The current price of token in 10 decimals
    /// @param deadline The deadline is validity of the signature
    /// @param referenceNormalizationFactor The normalization factor
    /// @param v The `v` signature parameter
    /// @param r The `r` signature parameter
    /// @param s The `s` signature parameter
    function purchaseNodeNFT(
        IERC20 token,
        uint256 quantity,
        uint256 referenceTokenPrice,
        uint256 deadline,
        uint8 referenceNormalizationFactor,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external payable canBuy(token, deadline) nonReentrant {
        // The input must have been signed by the presale signer
        _verifySignature(
            keccak256(abi.encodePacked(msg.sender, referenceNormalizationFactor, referenceTokenPrice, deadline, token)),
            v,
            r,
            s
        );

        (uint256 latestPrice, uint8 normalizationFactor) = _validatePrice(
            token,
            referenceTokenPrice,
            referenceNormalizationFactor
        );

        uint256 purchaseAmount = (quantity * nodeNFTPrice * (10 ** normalizationFactor)) / latestPrice;
        _checkZeroValue(purchaseAmount);

        if (token == ETH) {
            payable(nodeFundsWallet).sendValue(purchaseAmount);
        } else {
            token.safeTransferFrom(msg.sender, nodeFundsWallet, purchaseAmount);
        }

        nodeNft.mint(msg.sender, quantity);

        emit NodeNftPurchased({
            token: token,
            tokenPrice: latestPrice,
            by: msg.sender,
            amountPurchased: purchaseAmount,
            quantity: quantity
        });
    }

    /// @notice Purchases miner nft with token
    /// @param token The token used for purchasing
    /// @param referenceTokenPrice The current price of token in 10 decimals
    /// @param deadline The deadline is validity of the signature
    /// @param quantities The amount of each miner nft that user will purchase
    /// @param referenceNormalizationFactor The normalization factor
    /// @param v The `v` signature parameter
    /// @param r The `r` signature parameter
    /// @param s The `s` signature parameter
    function purchaseMinerNFT(
        IERC20 token,
        uint256 referenceTokenPrice,
        uint256 deadline,
        uint256[3] calldata quantities,
        uint8 referenceNormalizationFactor,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external payable canBuy(token, deadline) nonReentrant {
        // The input must have been signed by the presale signer
        _verifySignature(
            keccak256(abi.encodePacked(msg.sender, referenceNormalizationFactor, referenceTokenPrice, deadline, token)),
            v,
            r,
            s
        );

        uint256[3] memory minerPrices = minerNFTPrices;

        (uint256 purchaseAmount, uint256 latestPrice) = _processPurchase(
            token,
            referenceTokenPrice,
            quantities,
            referenceNormalizationFactor,
            false
        );

        if (token == ETH) {
            payable(minerFundsWallet).sendValue(purchaseAmount);
        } else {
            token.safeTransferFrom(msg.sender, minerFundsWallet, purchaseAmount);
        }

        emit MinerNftPurchased({
            token: token,
            tokenPrice: latestPrice,
            by: msg.sender,
            minerPrices: minerPrices,
            quantities: quantities,
            amountPurchased: purchaseAmount
        });
    }

    /// @notice Purchases miner nft on discounted price
    /// @param token The token used for purchasing
    /// @param referenceTokenPrice The current price of token in 10 decimals
    /// @param deadline The deadline is validity of the signature
    /// @param quantities The amount of each miner nft that user will purchase
    /// @param percentages The leader's percentages
    /// @param leaders The addresses of the leaders
    /// @param referenceNormalizationFactor The normalization factor
    /// @param code The code is used to verify signature of the user
    /// @param v The `v` signature parameter
    /// @param r The `r` signature parameter
    /// @param s The `s` signature parameter
    function purchaseMinerNFTDiscount(
        IERC20 token,
        uint256 referenceTokenPrice,
        uint256 deadline,
        uint256[3] calldata quantities,
        uint256[] calldata percentages,
        address[] calldata leaders,
        uint8 referenceNormalizationFactor,
        string memory code,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external payable canBuy(token, deadline) nonReentrant {
        // The input must have been signed by the presale signer
        _verifySignature(
            keccak256(
                abi.encodePacked(
                    msg.sender,
                    code,
                    percentages,
                    leaders,
                    referenceNormalizationFactor,
                    referenceTokenPrice,
                    deadline,
                    token
                )
            ),
            v,
            r,
            s
        );

        uint256[3] memory minerPrices = minerNFTPrices;

        (uint256 purchaseAmount, uint256 latestPrice) = _processPurchase(
            token,
            referenceTokenPrice,
            quantities,
            referenceNormalizationFactor,
            true
        );

        _transferAndUpdateCommissions(token, purchaseAmount, leaders, percentages);

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

    /// @dev Processes miner nft purchase
    function _processPurchase(
        IERC20 token,
        uint256 referenceTokenPrice,
        uint256[3] calldata quantities,
        uint8 referenceNormalizationFactor,
        bool isDiscounted
    ) private returns (uint256, uint256) {
        (uint256 latestPrice, uint8 normalizationFactor) = _validatePrice(
            token,
            referenceTokenPrice,
            referenceNormalizationFactor
        );

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
                    minerNFTPrices[i] += (minerNFTPrices[i] * priceAccretionPercentagePPM) / PPM;
                }
            }
        }

        return ((prices * (10 ** normalizationFactor)) / latestPrice, latestPrice);
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

    /// @notice Changes the miner price accretion percentage
    /// @param newPriceAccretionPercent The new price accretion percentage value
    function updateMinerPriceAccretionPercent(uint256 newPriceAccretionPercent) external onlyOwner {
        uint256 oldPriceAccretionPercent = priceAccretionPercentagePPM;

        if (newPriceAccretionPercent == oldPriceAccretionPercent) {
            revert IdenticalValue();
        }

        emit PriceAccretionPercentageUpdated({
            oldPriceAccretionPercent: oldPriceAccretionPercent,
            newPriceAccretionPercent: newPriceAccretionPercent
        });

        priceAccretionPercentagePPM = newPriceAccretionPercent;
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

    /// @notice Changes platform wallet address
    /// @param newPlatformWallet The address of the new platform wallet
    function updatePlatformWallet(address newPlatformWallet) external checkAddressZero(newPlatformWallet) onlyOwner {
        address oldPlatformWallet = platformWallet;

        if (oldPlatformWallet == newPlatformWallet) {
            revert IdenticalValue();
        }

        emit PlatformWalletUpdated({ oldPlatformWallet: oldPlatformWallet, newPlatformWallet: newPlatformWallet });

        platformWallet = newPlatformWallet;
    }

    /// @notice Changes project wallet address
    /// @param newProjectWallet The address of the new project wallet
    function updateProjectWallet(address newProjectWallet) external checkAddressZero(newProjectWallet) onlyOwner {
        address oldProjectWallet = projectWallet;

        if (oldProjectWallet == newProjectWallet) {
            revert IdenticalValue();
        }

        emit ProjectWalletUpdated({ oldProjectWallet: oldProjectWallet, newProjectWallet: newProjectWallet });

        projectWallet = newProjectWallet;
    }

    /// @notice Changes burn wallet address
    /// @param newBurnWallet The address of the new burn wallet
    function updateBurnWallet(address newBurnWallet) external checkAddressZero(newBurnWallet) onlyOwner {
        address oldBurnWallet = burnWallet;

        if (oldBurnWallet == newBurnWallet) {
            revert IdenticalValue();
        }

        emit BurnWalletUpdated({ oldBurnWallet: oldBurnWallet, newBurnWallet: newBurnWallet });

        burnWallet = newBurnWallet;
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

    /// @notice Updates the status of the tokens for purchases
    /// @param tokens The addresses of the tokens
    /// @param statuses The updated status of the tokens
    function updateAllowedTokens(IERC20[] calldata tokens, bool[] calldata statuses) external onlyOwner {
        uint256 tokensLength = tokens.length;

        if (tokensLength != statuses.length) {
            revert ArrayLengthMismatch();
        }

        for (uint256 i; i < tokensLength; ++i) {
            IERC20 token = tokens[i];
            bool status = statuses[i];

            if (address(token) == address(0)) {
                revert ZeroAddress();
            }

            if (allowedTokens[token] == status) {
                revert IdenticalValue();
            }

            allowedTokens[token] = status;

            emit AllowedTokenUpdated({ token: token, status: status });
        }
    }

    /// @dev Calculates and transfers amount to wallets
    function _calculateAndTransferAmounts(IERC20 token, uint256 amount) private {
        _checkZeroValue(amount);
        uint256 burnWalletAmount = (amount * BURN_PERCENTAGE_PPM) / PPM;
        uint256 platformWalletAmount = (amount * PLATFORM_PERCENTAGE_PPM) / PPM;
        token.safeTransferFrom(msg.sender, burnWallet, burnWalletAmount);
        token.safeTransferFrom(msg.sender, platformWallet, platformWalletAmount);
        token.safeTransferFrom(msg.sender, projectWallet, amount - (burnWalletAmount + platformWalletAmount));
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

    /// @dev Provides us live price of token from price feed or returns reference price and reverts if price is zero
    function _validatePrice(
        IERC20 token,
        uint256 referenceTokenPrice,
        uint8 referenceNormalizationFactor
    ) private view returns (uint256, uint8) {
        TokenInfo memory tokenInfo = tokenRegistry.getLatestPrice(token);
        if (tokenInfo.latestPrice != 0) {
            if (referenceTokenPrice != 0 || referenceNormalizationFactor != 0) {
                revert CodeSyncIssue();
            }
        }
        //  If price feed isn't available,we fallback to the reference price
        if (tokenInfo.latestPrice == 0) {
            if (referenceTokenPrice == 0 || referenceNormalizationFactor == 0) {
                revert ZeroValue();
            }

            tokenInfo.latestPrice = referenceTokenPrice;
            tokenInfo.normalizationFactor = referenceNormalizationFactor;
        }

        return (tokenInfo.latestPrice, tokenInfo.normalizationFactor);
    }

    /// @dev Checks zero address, if zero then reverts
    /// @param which The `which` address to check for zero address
    function _checkAddressZero(address which) private pure {
        if (which == address(0)) {
            revert ZeroAddress();
        }
    }

    /// @dev Checks buyEnabled,token allowed, user not blacklisted and time less than deadline, if not then reverts
    function _canBuy(IERC20 token, uint256 deadline) private view {
        if (!buyEnabled) {
            revert BuyNotEnabled();
        }

        if (blacklistAddress[msg.sender]) {
            revert Blacklisted();
        }

        if (!allowedTokens[token]) {
            revert TokenNotAllowed();
        }

        if (block.timestamp > deadline) {
            revert DeadlineExpired();
        }
    }

    /// @dev Calculates, transfers and update commissions
    function _transferAndUpdateCommissions(
        IERC20 token,
        uint256 amount,
        address[] memory leaders,
        uint256[] memory percentages
    ) private {
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

        ClaimInfo[] memory claimInfo = new ClaimInfo[](toLength);

        for (uint256 i; i < toLength; ++i) {
            uint256 percentage = percentages[i];
            sumPercentage += percentage;
            claimInfo[i] = ClaimInfo({ token: token, amount: (amount * percentage) / PPM });
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
        } else {
            amount -= (amount * CLAIMS_PERCENTAGE_PPM) / PPM;
        }

        if (token == ETH) {
            payable(minerFundsWallet).sendValue(amount);
            payable(address(claimsContract)).sendValue(equivalence);
        } else {
            token.safeTransferFrom(msg.sender, minerFundsWallet, amount);
            token.safeTransferFrom(msg.sender, address(claimsContract), equivalence);
        }

        claimsContract.addClaimInfo(leaders, claimInfo);
    }
}
