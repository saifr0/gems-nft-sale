// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

interface IMiner {
    /// @notice Checks the nft balance
    /// @param account The user account
    /// @param id The nft id
    function balanceOf(address account, uint256 id) external returns (uint256);
}
