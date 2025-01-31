// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import { ERC1155 } from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

/// @title MinerNft contract
/// @notice Implements ERC1155 nft contract
contract MinerNft is ERC1155 {
    /// @dev Constructor
    constructor() ERC1155("") {}

    /// @notice Mints nft to `to`, only callable by presale contract
    /// @param to The nft will be minted to `to`
    /// @param id The nft id to mint
    /// @param quantity The amount of ids to mint
    function mint(address to, uint256 id, uint256 quantity) external {
        _mint(to, id, quantity, "");
    }
}
