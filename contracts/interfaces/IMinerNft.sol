// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

interface IMinerNft {
    /// @notice Returns the user's nfts balance
    /// @param account The address of the user
    /// @param id The nft id
    function balanceOf(address account, uint256 id) external view returns (uint256);
}
