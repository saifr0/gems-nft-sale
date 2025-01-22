// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

/// @member latestPrice The price of token from price feed
/// @member normalizationFactor The normalization factor to achieve return value of 18 decimals ,while calculating token purchases and always with different token decimals
struct TokenInfo {
    uint256 latestPrice;
    uint8 normalizationFactor;
}

/// @dev The constant value helps in calculating percentages
uint256 constant PPM = 1_000_000;

/// @notice Thrown when updating an address with zero address
error ZeroAddress();

/// @notice Thrown when updating with an array of no values
error ZeroLengthArray();

/// @notice Thrown when updating with the same value as previously stored
error IdenticalValue();

/// @notice Thrown when two array lengths does not match
error ArrayLengthMismatch();

/// @notice Thrown when sign is invalid
error InvalidSignature();

/// @notice Thrown when value to transfer is zero
error ZeroValue();

/// @notice Thrown when input array length is zero
error InvalidData();
