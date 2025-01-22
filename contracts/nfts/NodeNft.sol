// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.25;

import { ERC721A } from "erc721a/contracts/ERC721A.sol";
import { Ownable2Step, Ownable } from "@openzeppelin/contracts/access/Ownable2Step.sol";

import { ZeroAddress, IdenticalValue } from "../utils/Common.sol";

contract NodeNft is ERC721A, Ownable2Step {
    // @notice Returns the address of the presale contract
    address public presale;

    /// @dev Emitted when token presale contract is updated
    event PresaleUpdated(address prevAddress, address newAddress);

    /// @notice Thrown when caller is not presale contract
    error OnlyPresale();

    constructor(address owner) ERC721A("Node-NFT", "Node-NFT") Ownable(owner) {}

    function mint(address to, uint256 quantity) external {
        if (msg.sender != presale) {
            revert OnlyPresale();
        }

        _mint(to, quantity);
    }

    /// @notice Updates presale contract address in claims
    /// @param newPresale The address of the presale contract
    function updatePresaleAddress(address newPresale) external onlyOwner {
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
}
