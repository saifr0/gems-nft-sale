// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

interface IMinerNft {
    /// @notice Mints the nft
    /// @param account The amount of nfts
    /// @param id The amount of nfts
    /// @param amount The amount of nfts
    function mint(address account, uint256 id, uint256 amount) external;
}
