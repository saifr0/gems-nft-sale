// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { AccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";
import { ReentrancyGuardTransient } from "@openzeppelin/contracts/utils/ReentrancyGuardTransient.sol";

import { IClaims } from "./interfaces/IClaims.sol";

import { InvalidData, ZeroValue, ArrayLengthMismatch, ZeroAddress, IdenticalValue, ZeroLengthArray, InvalidSignature } from "./utils/Common.sol";

/// @title Claims contract
/// @notice Implements the claiming of the leader's commissions
contract Claims is IClaims, AccessControl, ReentrancyGuardTransient {
    using SafeERC20 for IERC20;

    /// @dev The constant value helps in calculating time
    uint256 private constant ONE_WEEK_SECONDS = 604800;

    /// @notice Returns the identifier of the ADMIN_ROLE role
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN");

    /// @notice The address of the USDT contract
    IERC20 public immutable USDT;

    /// @notice Returns the address of the presale contract
    address public presale;

    /// @notice The address of funds wallet
    address public fundsWallet;

    /// @notice The current week number
    uint256 public currentWeek;

    /// @notice Stores the end time of the given week number
    mapping(uint256 week => uint256 endTime) public endTimes;

    /// @notice Stores the claim amount of the leader
    mapping(address => mapping(uint256 => uint256)) public pendingClaims;

    /// @dev Emitted when claim amount is set for the addresses
    event ClaimSet(address indexed to, uint256 indexed week, uint256 endTime, uint256 amount);

    /// @dev Emitted when claim amount is claimed
    event FundsClaimed(address indexed by, uint256 indexed week, uint256 amount);

    /// @dev Emitted when address of funds wallet is updated
    event FundsWalletUpdated(address oldFundsWallet, address newFundsWallet);

    /// @dev Emitted when presale contract is updated
    event PresaleUpdated(address prevAddress, address newAddress);

    /// @dev Emitted when claim is revoked for the user
    event ClaimRevoked(address leader, uint256 amount, uint256 week);

    /// @dev Emitted when claim is added for the user
    event ClaimsUpdated(address leader, uint256 amount, uint256 week);

    /// @notice Thrown when claiming before week ends
    error WeekNotEnded();

    /// @notice Thrown when caller is not presale contract
    error OnlyPresale();

    /// @dev Constructor
    /// @param fundsAddress The address of funds wallet
    constructor(address fundsAddress, IERC20 usdtAddress) {
        if (fundsAddress == address(0) || address(usdtAddress) == address(0)) {
            revert ZeroAddress();
        }

        fundsWallet = fundsAddress;
        _setRoleAdmin(ADMIN_ROLE, ADMIN_ROLE);
        _grantRole(ADMIN_ROLE, msg.sender);
        currentWeek++;
        endTimes[currentWeek] = block.timestamp + ONE_WEEK_SECONDS;
        USDT = usdtAddress;
    }

    /// @inheritdoc IClaims
    function addClaimInfo(address[] calldata to, uint256[] calldata amounts) external {
        if (msg.sender != address(presale)) {
            revert OnlyPresale();
        }

        uint256 toLength = to.length;

        if (toLength == 0) {
            revert InvalidData();
        }

        if (toLength != amounts.length) {
            revert ArrayLengthMismatch();
        }

        uint256 prevEndTime = endTimes[currentWeek];

        if (block.timestamp >= prevEndTime) {
            uint256 weeksElapsed = ((block.timestamp - prevEndTime) / ONE_WEEK_SECONDS) + 1;

            currentWeek += weeksElapsed;
            endTimes[currentWeek] = prevEndTime + (weeksElapsed * ONE_WEEK_SECONDS);
        }

        uint256 week = currentWeek;

        for (uint256 i; i < toLength; ++i) {
            address leader = to[i];
            uint256 amount = amounts[i];

            if (leader == address(0)) {
                revert ZeroAddress();
            }

            pendingClaims[leader][week] += amount;

            emit ClaimSet({ to: leader, week: week, endTime: endTimes[week], amount: amount });
        }
    }

    /// @notice Revokes leader claim
    /// @param leaders The addresses of the leaders
    /// @param amounts The revoke amount of the leader
    /// @param week The week number
    function revokeLeaderClaim(
        address[] calldata leaders,
        uint256[] calldata amounts,
        uint256 week
    ) external onlyRole(ADMIN_ROLE) {
        _updateOrRevokeClaim(leaders, amounts, week, true);
    }

    /// @notice Updates leader claim
    /// @param leaders The addresses of the leaders
    /// @param amounts The revoke amount of the leader
    /// @param week The week number
    function updateClaims(
        address[] calldata leaders,
        uint256[] calldata amounts,
        uint256 week
    ) external onlyRole(ADMIN_ROLE) {
        _updateOrRevokeClaim(leaders, amounts, week, false);
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

    /// @notice Gives max allowance of USDT to presale contract
    function approveAllowance() external onlyRole(ADMIN_ROLE) {
        USDT.forceApprove(address(presale), type(uint256).max);
    }

    /// @notice Claims the amount in a given week
    /// @param week The week in which you want to claim
    function claim(uint256 week) external nonReentrant {
        if (block.timestamp < endTimes[week]) {
            revert WeekNotEnded();
        }

        uint256 amount = pendingClaims[msg.sender][week];

        if (amount == 0) {
            revert ZeroValue();
        }

        delete pendingClaims[msg.sender][week];
        USDT.safeTransfer(msg.sender, amount);

        emit FundsClaimed({ by: msg.sender, week: week, amount: amount });
    }

    /// @notice Claims the amount in a given week
    /// @param claimWeeks The array of weeks for which you want to claim
    function claimAll(uint256[] calldata claimWeeks) external nonReentrant {
        if (claimWeeks.length == 0) {
            revert ZeroLengthArray();
        }

        uint256 totalAmount;

        for (uint256 i; i < claimWeeks.length; ++i) {
            uint256 week = claimWeeks[i];

            uint256 amount = pendingClaims[msg.sender][week];

            if (block.timestamp < endTimes[week] || amount == 0) {
                continue;
            }

            totalAmount += amount;
            delete pendingClaims[msg.sender][week];

            emit FundsClaimed({ by: msg.sender, week: week, amount: amount });
        }

        if (totalAmount == 0) {
            revert ZeroValue();
        }

        USDT.safeTransfer(msg.sender, totalAmount);
    }

    /// @dev Revokes or updates leader claims
    /// @param leaders The addresses of the leaders
    /// @param amounts The revoke amount of the leader
    /// @param week The week number
    /// @param isRevoke Boolean for revoke or update claims
    function _updateOrRevokeClaim(
        address[] calldata leaders,
        uint256[] calldata amounts,
        uint256 week,
        bool isRevoke
    ) private {
        uint256 leadersLength = leaders.length;

        if (leadersLength == 0) {
            revert ZeroLengthArray();
        }

        if (amounts.length != leadersLength) {
            revert ArrayLengthMismatch();
        }

        for (uint256 i; i < leadersLength; ++i) {
            address leader = leaders[i];
            uint256 amount = amounts[i];

            if (isRevoke) {
                pendingClaims[leader][week] -= amount;
                USDT.safeTransfer(fundsWallet, amount);

                emit ClaimRevoked(leader, amount, week);
            } else {
                pendingClaims[leader][week] += amount;

                emit ClaimsUpdated(leader, amount, week);
            }
        }
    }
}
