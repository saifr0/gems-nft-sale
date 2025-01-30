// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import { SafeERC20, IERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { ReentrancyGuardTransient } from "@openzeppelin/contracts/utils/ReentrancyGuardTransient.sol";
import { Ownable2Step, Ownable } from "@openzeppelin/contracts/access/Ownable2Step.sol";

import { IMinerNft } from "./interfaces/IMinerNft.sol";
import { INodeNft } from "./interfaces/INodeNft.sol";

import { ZeroAddress, IdenticalValue, ArrayLengthMismatch, InvalidData, ZeroValue } from "./utils/Common.sol";

/// @title Rewards contract
/// @notice Implements claiming of the user's miner and node rewards
/// @dev The rewards contract allows user to claim the miner and node rewards
contract Rewards is Ownable2Step, ReentrancyGuardTransient {
    using SafeERC20 for IERC20;

    /// @notice The address of the miner nft contract
    IMinerNft public immutable minerNft;

    /// @notice The address of the node nft contract
    INodeNft public immutable nodeNft;

    /// @notice The addresses of the tokens
    IERC20[] public tokens;

    /// @notice The reward amounts of the miner nfts
    uint256[] public minerRewards;

    /// @notice The reward amounts of the node nfts
    uint256[] public nodeRewards;

    /// @notice Returns the access info of the rewards claim
    bool public rewardEnabled;

    /// @notice The address of the funds wallet
    address public fundsWallet;

    /// @notice Gives info about user's miner rewards claim
    mapping(address => bool) public minerClaimed;

    /// @notice Gives info about user's nodes rewards claim
    mapping(address => bool) public nodeClaimed;

    /// @dev Emitted when address of funds wallet is updated
    event FundsWalletUpdated(address oldFundsWallet, address newFundsWallet);

    /// @dev Emitted when node rewards amounts are updated
    event NodeRewardUpdated(IERC20 token, uint256 oldReward, uint256 newReward);

    /// @dev Emitted when miner rewards amounts are updated
    event MinerRewardUpdated(IERC20 token, uint256 oldReward, uint256 newReward);

    /// @dev Emitted when tokens associated with reward are updated
    event TokenUpdated(IERC20 oldToken, IERC20 newToken);

    /// @dev Emitted when reward enabled is updated
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
    /// @param tokensAddresses The addresses of the tokens
    /// @param minerRewardsInit The reward amounts of miner nfts
    /// @param nodeRewardsInit The reward amounts of node nfts
    constructor(
        address fundsWalletAddress,
        address owner,
        IMinerNft minerNftAddress,
        INodeNft nodeNftAddress,
        IERC20[] memory tokensAddresses,
        uint256[] memory minerRewardsInit,
        uint256[] memory nodeRewardsInit
    ) Ownable(owner) {
        if (
            fundsWalletAddress == address(0) ||
            address(minerNftAddress) == address(0) ||
            address(nodeNftAddress) == address(0)
        ) {
            revert ZeroAddress();
        }

        if (tokensAddresses.length == 0) {
            revert InvalidData();
        }

        if (tokensAddresses.length != minerRewardsInit.length || tokensAddresses.length != nodeRewardsInit.length) {
            revert ArrayLengthMismatch();
        }

        for (uint256 i; i < tokensAddresses.length; ++i) {
            if (address(tokensAddresses[i]) == address(0)) {
                revert ZeroAddress();
            }
        }

        for (uint256 i; i < minerRewardsInit.length; ++i) {
            if (minerRewardsInit[i] == 0 || minerRewardsInit[i] == 0) {
                revert ZeroValue();
            }
        }

        fundsWallet = fundsWalletAddress;
        minerNft = minerNftAddress;
        nodeNft = nodeNftAddress;
        tokens = tokensAddresses;
        minerRewards = minerRewardsInit;
        nodeRewards = nodeRewardsInit;
    }

    /// @notice Changes funds wallet address
    /// @param newFundsWallet The address of the new funds wallet
    function updateFundsWallet(address newFundsWallet) external onlyOwner {
        address oldFundsWallet = fundsWallet;

        if (oldFundsWallet == address(0)) {
            revert ZeroAddress();
        }
        if (oldFundsWallet == newFundsWallet) {
            revert IdenticalValue();
        }

        emit FundsWalletUpdated({ oldFundsWallet: oldFundsWallet, newFundsWallet: newFundsWallet });

        fundsWallet = newFundsWallet;
    }

    /// @notice Changes the token addresses
    /// @param newTokens The new token addresses associated with rewards
    function updateTokens(IERC20[] memory newTokens) external onlyOwner {
        if (newTokens.length != tokens.length) {
            revert ArrayLengthMismatch();
        }

        for (uint256 i = 0; i < newTokens.length; ++i) {
            IERC20 oldToken = tokens[i];

            if (oldToken == newTokens[i]) {
                revert IdenticalValue();
            }

            if (address(newTokens[i]) == address(0)) {
                revert ZeroAddress();
            }

            tokens[i] = newTokens[i];

            emit TokenUpdated({ oldToken: oldToken, newToken: newTokens[i] });
        }
    }

    /// @notice Changes the node nft rewards
    /// @param newRewards The new reward amounts for each token associated with node NFTs
    function updateNodeRewards(uint256[] memory newRewards) external onlyOwner {
        if (newRewards.length != nodeRewards.length) {
            revert ArrayLengthMismatch();
        }

        for (uint256 i = 0; i < newRewards.length; ++i) {
            uint256 oldReward = nodeRewards[i];

            if (oldReward == newRewards[i]) {
                revert IdenticalValue();
            }

            if (newRewards[i] == 0) {
                revert ZeroValue();
            }

            nodeRewards[i] = newRewards[i];

            emit NodeRewardUpdated({ token: tokens[i], oldReward: oldReward, newReward: newRewards[i] });
        }
    }

    /// @notice Changes the miner nft rewards
    /// @param newRewards The new reward amounts for each token associated with miner NFTs
    function updateMinerRewards(uint256[] memory newRewards) external onlyOwner {
        if (newRewards.length != minerRewards.length) {
            revert ArrayLengthMismatch();
        }

        for (uint256 i = 0; i < newRewards.length; ++i) {
            uint256 oldReward = minerRewards[i];

            if (oldReward == newRewards[i]) {
                revert IdenticalValue();
            }

            if (newRewards[i] == 0) {
                revert ZeroValue();
            }

            minerRewards[i] = newRewards[i];

            emit MinerRewardUpdated({ token: tokens[i], oldReward: oldReward, newReward: newRewards[i] });
        }
    }

    /// @notice Claims the miner nft rewards
    /// @param ids The nft ids that user holds
    function claimMinerRewards(uint256[] calldata ids) external nonReentrant {
        if (minerClaimed[msg.sender]) {
            revert AlreadyClaimed();
        }

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 minerBalance = minerNft.balanceOf(msg.sender, id);
            _claimRewards(minerBalance);
        }

        minerClaimed[msg.sender] = true;
    }

    /// @notice Claims the node nft rewards
    function claimNodeRewards() external nonReentrant {
        if (nodeClaimed[msg.sender]) {
            revert AlreadyClaimed();
        }

        uint256 nodeBalance = nodeNft.balanceOf(msg.sender);
        _claimRewards(nodeBalance);

        nodeClaimed[msg.sender] = true;
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

    /// @dev Processes claiming of miner and node rewards
    function _claimRewards(uint256 balance) private {
        uint256 tokensLength = tokens.length;

        if (!rewardEnabled) {
            revert NotAllowed();
        }

        if (balance > 0) {
            for (uint256 i = 0; i < tokensLength; ++i) {
                uint256 amount = nodeRewards[i] * balance;
                tokens[i].safeTransferFrom(fundsWallet, msg.sender, amount);

                emit RewardsClaimed({ by: msg.sender, token: tokens[i], amount: amount });
            }
        }
    }
}
