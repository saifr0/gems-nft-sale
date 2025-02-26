// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

interface INodeNft {
    /// @notice Mints the nft
    /// @param quantity The amount of nfts
    function mint(address to, uint256 quantity) external;

    /// @notice Returns the owner of the `tokenId` token.
    /// @param nftId The nft id
    function ownerOf(uint256 nftId) external view returns (address);
}
