// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import { SafeERC20, IERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { AccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";
import { ReentrancyGuardTransient } from "@openzeppelin/contracts/utils/ReentrancyGuardTransient.sol";
import { IClaims, ClaimInfo } from "./interfaces/IClaims.sol";

import { InvalidData, ArrayLengthMismatch, ZeroAddress, IdenticalValue, ZeroLengthArray } from "./utils/Common.sol";

/// @title Claims contract
/// @notice Implements the claiming of the leader's commissions
contract Claims is IClaims, AccessControl, ReentrancyGuardTransient {
    using SafeERC20 for IERC20;

    /// @notice Returns the identifier of the COMMISSIONS_MANAGER role
    bytes32 public constant COMMISSIONS_MANAGER = keccak256("COMMISSIONS_MANAGER");

    /// @notice Returns the identifier of the ADMIN_ROLE role
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN");

    /// @notice Returns the address of the presale contract
    address public presale;

    /// @notice The address of funds wallet
    address public fundsWallet;

    /// @notice Stores the claim amount of user for the token
    mapping(address => mapping(IERC20 => uint256)) public pendingClaims;

    /// @notice Stores the enabled/disabled status
    bool public isEnabled;

    /// @dev Emitted when claim amount is set for the addresses
    event ClaimSet(address indexed to, ClaimInfo claimInfo);

    /// @dev Emitted when claim amount is claimed
    event FundsClaimed(address indexed by, IERC20 token, uint256 amount);

    /// @dev Emitted when claim access changes
    event ClaimsEnableUpdated(bool oldAccess, bool newAccess);

    /// @dev Emitted when address of funds wallet is updated
    event FundsWalletUpdated(address oldFundsWallet, address newFundsWallet);

    /// @dev Emitted when token presale contract is updated
    event PresaleUpdated(address prevAddress, address newAddress);

    /// @dev Emitted when claim is revoked for the user
    event ClaimRevoked(address leader, IERC20 token, uint256 amount);

    /// @dev Emitted when claim is added for the user
    event ClaimsUpdated(address leader, IERC20 token, uint256 amount);

    /// @notice Thrown when caller is not presale contract
    error OnlyPresale();

    /// @dev Constructor
    /// @param fundsWalletAddress The address of funds Wallet
    constructor(address fundsWalletAddress) {
        if (fundsWalletAddress == address(0)) {
            revert ZeroAddress();
        }

        fundsWallet = fundsWalletAddress;
        _setRoleAdmin(ADMIN_ROLE, ADMIN_ROLE);
        _setRoleAdmin(COMMISSIONS_MANAGER, ADMIN_ROLE);
        _grantRole(ADMIN_ROLE, msg.sender);
    }

    /// @inheritdoc IClaims
    function addClaimInfo(address[] calldata to, ClaimInfo[] calldata claims) external {
        if (msg.sender != presale) {
            revert OnlyPresale();
        }

        uint256 toLength = to.length;

        if (toLength == 0) {
            revert InvalidData();
        }

        if (toLength != claims.length) {
            revert ArrayLengthMismatch();
        }

        for (uint256 i; i < toLength; ++i) {
            address leader = to[i];

            if (leader == address(0)) {
                revert ZeroAddress();
            }

            mapping(IERC20 => uint256) storage claimInfo = pendingClaims[leader];
            ClaimInfo[] calldata toClaim = claims;
            ClaimInfo memory amount = toClaim[i];
            claimInfo[amount.token] += amount.amount;

            emit ClaimSet({ to: leader, claimInfo: amount });
        }
    }

    /// @notice Revokes leader claim for the given token
    /// @param leaders The addresses of the leaders
    /// @param tokens Tokens of the leader whose claims will be revoked
    /// @param amounts The revoke amount of each token of the leader
    function revokeLeaderClaim(address[] calldata leaders, IERC20[][] calldata tokens, uint256[][] calldata amounts) external onlyRole(ADMIN_ROLE) {
        _updateOrRevokeClaim(leaders, tokens, amounts, true);
    }

    /// @notice Updates leader claim for the given token
    /// @param leaders The addresses of the leaders
    /// @param tokens Tokens of the leader whose claims will be revoked
    /// @param amounts The revoke amount of each token of the leader
    function updateClaims(address[] calldata leaders, IERC20[][] calldata tokens, uint256[][] calldata amounts) external onlyRole(ADMIN_ROLE) {
        _updateOrRevokeClaim(leaders, tokens, amounts, false);
    }

    /// @notice Updates presale contract address in claims
    /// @param newPresale The address of the presale contract
    function updatePresaleAddress(address newPresale) external onlyRole(ADMIN_ROLE) {
        address oldPresaleAddress = presale;

        if (newPresale == address(0)) {
            revert ZeroAddress();
        }

        if (oldPresaleAddress == newPresale) {
            revert IdenticalValue();
        }

        emit PresaleUpdated({ prevAddress: oldPresaleAddress, newAddress: newPresale });

        presale = newPresale;
    }

    /// @notice Changes funds wallet to a new address
    /// @param newFundsWallet The address of the new funds wallet
    function changeFundsWallet(address newFundsWallet) external onlyRole(ADMIN_ROLE) {
        address oldFundsWallet = fundsWallet;

        if (newFundsWallet == address(0)) {
            revert ZeroAddress();
        }

        if (oldFundsWallet == newFundsWallet) {
            revert IdenticalValue();
        }

        emit FundsWalletUpdated({ oldFundsWallet: oldFundsWallet, newFundsWallet: newFundsWallet });

        fundsWallet = newFundsWallet;
    }

    /// @notice Changes the claim access of the contract
    /// @param status The access status
    function enableClaims(bool status) external onlyRole(COMMISSIONS_MANAGER) {
        bool oldAccess = isEnabled;

        if (oldAccess == status) {
            revert IdenticalValue();
        }

        emit ClaimsEnableUpdated({ oldAccess: oldAccess, newAccess: status });

        isEnabled = status;
    }

    /// @notice Claims the amount for the given tokens if exists
    function claim(IERC20[] calldata tokens) external nonReentrant {
        mapping(IERC20 => uint256) storage claimInfo = pendingClaims[msg.sender];
        uint256 tokensLength = tokens.length;

        for (uint256 i; i < tokensLength; ++i) {
            IERC20 token = tokens[i];
            uint256 amount = claimInfo[token];

            if (amount == 0) {
                continue;
            }

            delete claimInfo[token];
            token.safeTransfer(msg.sender, amount);

            emit FundsClaimed({ by: msg.sender, token: token, amount: amount });
        }
    }

    /// @dev Revokes or updates leader claims for the given token
    /// @param leaders The addresses of the leaders
    /// @param tokens Tokens of the leader whose claims will be revoked
    /// @param amounts The revoke amount of each token of the leader
    /// @param isRevoke Boolean for revoke or update claims
    function _updateOrRevokeClaim(address[] calldata leaders, IERC20[][] calldata tokens, uint256[][] calldata amounts, bool isRevoke) private {
        uint256 leadersLength = leaders.length;

        if (leadersLength == 0) {
            revert ZeroLengthArray();
        }

        if (tokens.length != amounts.length || amounts.length != leadersLength) {
            revert ArrayLengthMismatch();
        }

        for (uint256 i; i < leadersLength; ++i) {
            address leader = leaders[i];
            IERC20[] calldata leaderTokens = tokens[i];
            uint256[] calldata leaderAmounts = amounts[i];

            if (leaderTokens.length != leaderAmounts.length) {
                revert ArrayLengthMismatch();
            }

            mapping(IERC20 => uint256) storage claimInfo = pendingClaims[leader];

            for (uint256 j; j < leaderTokens.length; ++j) {
                IERC20 token = leaderTokens[j];
                uint256 amount = leaderAmounts[j];

                if (isRevoke) {
                    claimInfo[token] -= amount;
                    token.safeTransfer(fundsWallet, amount);
                    emit ClaimRevoked(leader, token, amount);
                } else {
                    claimInfo[token] += amount;

                    emit ClaimsUpdated(leader, token, amount);
                }
            }
        }
    }
}
