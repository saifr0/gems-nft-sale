// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import { SafeERC20, IERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { ReentrancyGuardTransient } from "@openzeppelin/contracts/utils/ReentrancyGuardTransient.sol";
import { Ownable2Step, Ownable } from "@openzeppelin/contracts/access/Ownable2Step.sol";

import { IMinerNft } from "./interfaces/IMinerNft.sol";
import { INodeNft } from "./interfaces/INodeNft.sol";

import { ZeroAddress, IdenticalValue, ArrayLengthMismatch, InvalidData } from "./utils/Common.sol";

/// @title Rewards contract
/// @notice Implements claiming of the user's rewards
/// @dev The rewards contract allows user to claim the rewards
contract Rewards is Ownable2Step, ReentrancyGuardTransient {
    using SafeERC20 for IERC20;

    /// @notice The address of the miner nft contract
    IMinerNft public immutable minerNft;

    /// @notice The address of the node nft contract
    INodeNft public immutable nodeNft;

    /// @notice Returns the access info of the transfer
    bool public rewardEnabled;

    /// @notice The address of the funds wallet
    address public fundsWallet;

    /// @notice Gives info about rewards claim
    mapping(address => bool) public rewardClaimed;

    /// @dev Emitted when address of node funds wallet is updated
    event FundsWalletUpdated(address oldFundsWallet, address newFundsWallet);

    /// @dev Emitted when transfer enabled is updated
    event RewardEnabled(bool enabled);

    /// @dev Emitted when reward amount is claimed
    event RewardsClaimed(address indexed by, IERC20 indexed token, uint256 amount);

    /// @notice Thrown when caller already claimed the rewards
    error AlreadyClaimed();

    /// @notice Thrown when trying to claim rewards while restricted
    error NotAllowed();

    /// @dev Constructor
    /// @param fundsWalletAddress The address of funds wallet
    /// @param owner The address of owner wallet
    /// @param minerNftAddress The address of miner nft contract
    /// @param nodeNftAddress The address of node nft contract
    constructor(
        address fundsWalletAddress,
        address owner,
        IMinerNft minerNftAddress,
        INodeNft nodeNftAddress
    ) Ownable(owner) {
        if (
            fundsWalletAddress == address(0) ||
            address(minerNftAddress) == address(0) ||
            address(nodeNftAddress) == address(0)
        ) {
            revert ZeroAddress();
        }

        fundsWallet = fundsWalletAddress;
        minerNft = minerNftAddress;
        nodeNft = nodeNftAddress;
    }

    /// @notice Claims the reward
    /// @param id The nft id that user holds
    /// @param tokens The addresses of the tokens
    /// @param amounts The amounts of tokens that will be transfer to user
    function claimRewards(uint256 id, IERC20[] memory tokens, uint256[] memory amounts) external nonReentrant {
        uint256 tokensLength = tokens.length;

        if (tokensLength == 0) {
            revert InvalidData();
        }

        if (tokensLength != amounts.length) {
            revert ArrayLengthMismatch();
        }

        if (rewardClaimed[msg.sender]) {
            revert AlreadyClaimed();
        }

        if (!rewardEnabled) {
            revert NotAllowed();
        }

        uint256 balance = minerNft.minerNFtBalanceOf(msg.sender, id);

        if (balance > 0) {
            for (uint256 i; i < tokensLength; ++i) {
                tokens[i].safeTransferFrom(fundsWallet, msg.sender, amounts[i]);

                emit RewardsClaimed({ by: msg.sender, token: tokens[i], amount: amounts[i] });
            }

            rewardClaimed[msg.sender] = true;
        }
    }

    /// @notice Enables or disables rewards
    /// @param enabled The decision to allow transfer or not
    function enableRewards(bool enabled) external onlyOwner {
        bool oldRewardEnabled = rewardEnabled;

        if (oldRewardEnabled == enabled) {
            revert IdenticalValue();
        }

        emit RewardEnabled({ enabled: enabled });

        rewardEnabled = enabled;
    }
}
