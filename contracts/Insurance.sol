// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import { SafeERC20, IERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { Address } from "@openzeppelin/contracts/utils/Address.sol";
import { ECDSA } from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import { MessageHashUtils } from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import { ReentrancyGuardTransient } from "@openzeppelin/contracts/utils/ReentrancyGuardTransient.sol";
import { Ownable2Step, Ownable } from "@openzeppelin/contracts/access/Ownable2Step.sol";

import { IMiner } from "./interfaces/IMiner.sol";
import { ITokenRegistry } from "./interfaces/ITokenRegistry.sol";

import { PPM, ETH, ZeroAddress, IdenticalValue, InvalidSignature, ZeroValue, TokenInfo } from "./utils/Common.sol";

/// @title Insurance contract
/// @notice Implements insurance of miner nfts
/// @dev The insurance contract allows you to purchase owned miners insurance
contract Insurance is Ownable2Step, ReentrancyGuardTransient {
    using SafeERC20 for IERC20;
    using Address for address payable;

    /// @notice The address of the miner nft contract
    IMiner public minerNft;

    /// @notice That buyEnabled or not
    bool public buyEnabled = true;

    /// @notice The address of the signer wallet
    address public signerWallet;

    /// @notice The address of the insurance funds wallet
    address public insuranceFundsWallet;

    /// @notice The address of the token registry contract
    ITokenRegistry public tokenRegistry;

    /// @notice The insurance fee in PPM
    uint256 public insuranceFeePPM;

    /// @notice Gives info about address's permission
    mapping(address => bool) public blacklistAddress;

    /// @dev Emitted when address of signer is updated
    event SignerUpdated(address oldSigner, address newSigner);

    /// @dev Emitted when address of insurance funds wallet is updated
    event InsuranceFundsWalletUpdated(address oldInsuranceFundsWallet, address newInsuranceFundsWallet);

    /// @dev Emitted when blacklist access of address is updated
    event BlacklistUpdated(address which, bool accessNow);

    /// @dev Emitted when buying access changes
    event BuyEnableUpdated(bool oldAccess, bool newAccess);

    /// @dev Emitted when insurance is purchased
    event InsurancePurchased(IERC20 token, address by, uint256[3] quantities, uint256 insuranceAmount, string trxHash);

    /// @dev Emitted when address of token registry contract is updated
    event TokenRegistryUpdated(ITokenRegistry oldTokenRegistry, ITokenRegistry newTokenRegistry);

    /// @dev Emitted when address of miner nft contract is updated
    event MinerNftUpdated(IMiner oldMinerNft, IMiner newMinerNft);

    /// @dev Emitted when insurance fee is updated
    event InsuranceFeeUpdated(uint256 oldInsuranceFee, uint256 newInsuranceFee);

    /// @notice Thrown when address is blacklisted
    error Blacklisted();

    /// @notice Thrown when buy is disabled
    error BuyNotEnabled();

    /// @notice Thrown when both price feed and reference price are non zero
    error CodeSyncIssue();

    /// @notice Thrown when sign deadline is expired
    error DeadlineExpired();

    /// @notice Thrown when user don't have nfts
    error InvalidPurchase();

    /// @dev Restricts when updating wallet/contract address with zero address
    modifier checkAddressZero(address which) {
        _checkAddressZero(which);
        _;
    }

    /// @dev Constructor
    /// @param insuranceFundsWalletAddress The address of insurance funds wallet
    /// @param signerAddress The address of signer wallet
    /// @param owner The address of owner wallet
    /// @param minerNftAddress The address of miner nft contract
    /// @param tokenRegistryAddress The address of token registry contract
    /// @param insuranceFeePPMInit The insurance fee
    constructor(
        address insuranceFundsWalletAddress,
        address signerAddress,
        address owner,
        IMiner minerNftAddress,
        ITokenRegistry tokenRegistryAddress,
        uint256 insuranceFeePPMInit
    )
        Ownable(owner)
        checkAddressZero(signerAddress)
        checkAddressZero(address(minerNftAddress))
        checkAddressZero(address(tokenRegistryAddress))
    {
        if (insuranceFeePPMInit == 0) {
            revert ZeroValue();
        }

        insuranceFundsWallet = insuranceFundsWalletAddress;
        signerWallet = signerAddress;
        minerNft = minerNftAddress;
        tokenRegistry = tokenRegistryAddress;
        insuranceFeePPM = insuranceFeePPMInit;
    }

    /// @notice Purchases insurance with any token
    /// @param token The token used in the purchase
    /// @param prices The prices of miners
    /// @param deadline The deadline is validity of the signature
    /// @param quantities The amount of each miner that you want to insure
    /// @param referenceTokenPrice The current price of token in 10 decimals
    /// @param referenceNormalizationFactor The normalization factor
    /// @param trxHash The normalization factor
    /// @param v The `v` signature parameter
    /// @param r The `r` signature parameter
    /// @param s The `s` signature parameter
    function purchaseInsurance(
        IERC20 token,
        uint256[3] calldata prices,
        uint256 deadline,
        uint256[3] calldata quantities,
        uint256 referenceTokenPrice,
        uint8 referenceNormalizationFactor,
        string calldata trxHash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external payable nonReentrant {
        if (!buyEnabled) {
            revert BuyNotEnabled();
        }

        if (blacklistAddress[msg.sender]) {
            revert Blacklisted();
        }

        if (block.timestamp > deadline) {
            revert DeadlineExpired();
        }

        for (uint256 i; i < prices.length; ++i) {
            if (prices[i] == 0) {
                revert ZeroValue();
            }
        }

        // The input must have been signed by the presale signer
        _verifySignature(
            keccak256(
                abi.encodePacked(
                    msg.sender,
                    token,
                    prices,
                    quantities,
                    referenceTokenPrice,
                    referenceNormalizationFactor,
                    trxHash,
                    deadline
                )
            ),
            v,
            r,
            s
        );

        (uint256 latestPrice, uint8 normalizationFactor) = _validatePrice(
            token,
            referenceTokenPrice,
            referenceNormalizationFactor
        );

        uint256 totalAmount;
        uint256 quantityLength = quantities.length;

        for (uint256 i; i < quantityLength; ++i) {
            uint256 quantity = quantities[i];

            if (quantity > 0) {
                totalAmount += (prices[i] * quantity);

                uint256 userBalance = minerNft.balanceOf(msg.sender, i);

                if (quantity > userBalance) {
                    revert InvalidPurchase();
                }
            }
        }

        uint256 insuranceAmount = (totalAmount * insuranceFeePPM) / PPM;
        insuranceAmount = (insuranceAmount * (10 ** normalizationFactor)) / latestPrice;

        if (insuranceAmount == 0) {
            revert ZeroValue();
        }

        if (token == ETH) {
            payable(insuranceFundsWallet).sendValue(insuranceAmount);

            if (msg.value > insuranceAmount) {
                payable(msg.sender).sendValue(msg.value - insuranceAmount);
            }
        } else {
            token.safeTransferFrom(msg.sender, insuranceFundsWallet, insuranceAmount);
        }

        emit InsurancePurchased({
            token: token,
            by: msg.sender,
            quantities: quantities,
            insuranceAmount: insuranceAmount,
            trxHash: trxHash
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

    /// @notice Changes insurance funds wallet address
    /// @param newInsuranceFundsWallet The address of the new insurance funds wallet
    function updateInsuranceFundsWallet(
        address newInsuranceFundsWallet
    ) external checkAddressZero(newInsuranceFundsWallet) onlyOwner {
        address oldInsuranceFundsWallet = insuranceFundsWallet;

        if (oldInsuranceFundsWallet == newInsuranceFundsWallet) {
            revert IdenticalValue();
        }

        emit InsuranceFundsWalletUpdated({
            oldInsuranceFundsWallet: oldInsuranceFundsWallet,
            newInsuranceFundsWallet: newInsuranceFundsWallet
        });

        insuranceFundsWallet = newInsuranceFundsWallet;
    }
    /// @notice Changes the insurance fee
    /// @param newInsuranceFee The new Insurance fee
    function updateInsuranceFee(uint256 newInsuranceFee) external onlyOwner {
        uint256 oldInsuranceFee = insuranceFeePPM;

        if (newInsuranceFee == oldInsuranceFee) {
            revert IdenticalValue();
        }

        if (newInsuranceFee == 0) {
            revert ZeroValue();
        }

        emit InsuranceFeeUpdated({ oldInsuranceFee: oldInsuranceFee, newInsuranceFee: newInsuranceFee });

        insuranceFeePPM = newInsuranceFee;
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

    /// @notice Changes miner nft contract address
    /// @param newMinerNft The address of the new miner nft contract
    function updateMinerNft(IMiner newMinerNft) external checkAddressZero(address(newMinerNft)) onlyOwner {
        IMiner oldMinerNft = minerNft;

        if (oldMinerNft == newMinerNft) {
            revert IdenticalValue();
        }

        emit MinerNftUpdated({ oldMinerNft: oldMinerNft, newMinerNft: newMinerNft });

        minerNft = newMinerNft;
    }

    /// @dev Verifies the address that signed a hashed message (`hash`) with `signature`
    function _verifySignature(bytes32 encodedMessageHash, uint8 v, bytes32 r, bytes32 s) private view {
        if (signerWallet != ECDSA.recover(MessageHashUtils.toEthSignedMessageHash(encodedMessageHash), v, r, s)) {
            revert InvalidSignature();
        }
    }

    /// @dev Validates the token price
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
        //  If price feed isn't available, we fallback to the reference price
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
}
