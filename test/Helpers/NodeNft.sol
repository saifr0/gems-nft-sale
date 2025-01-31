// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import { ERC721A } from "erc721a/contracts/ERC721A.sol";

/// @title NodeNft contract
/// @notice Implements ERC721A nft contract
contract NodeNft is ERC721A {
    /// @dev Constructor
    constructor() ERC721A("Gems Nodes", "GNODE") {}

    /// @notice Mints nft to `to`, only callable by presale contract
    /// @param to The nft will be minted to `to`
    /// @param quantity The amount of nfts to mint
    function mint(address to, uint256 quantity) external {
        _mint(to, quantity);
    }
}
