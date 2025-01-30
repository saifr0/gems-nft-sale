// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

/// @notice Thrown when updating an address with zero address
error ZeroAddress();

/// @notice Thrown when updating with the same value as previously stored
error IdenticalValue();

/// @notice Thrown when two array lengths does not match
error ArrayLengthMismatch();

/// @notice Thrown when value to transfer is zero
error ZeroValue();

/// @notice Thrown when input array length is zero
error InvalidData();
