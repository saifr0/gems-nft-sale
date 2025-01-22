// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import { ERC1155 } from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import { Ownable2Step, Ownable } from "@openzeppelin/contracts/access/Ownable2Step.sol";

import { ZeroAddress, IdenticalValue } from "../utils/Common.sol";

contract MinerNft is ERC1155, Ownable2Step {
    /// @notice Returns the address of the presale contract
    address public presale;

    /// @dev Emitted when token presale contract is updated
    event PresaleUpdated(address prevAddress, address newAddress);

    /// @notice Thrown when caller is not presale contract
    error OnlyPresale();

    error InvalidId();

    constructor(address owner) ERC1155("") Ownable(owner) {}

    function mint(address to, uint256 id, uint256 quantity) external {
        if (msg.sender != presale) {
            revert OnlyPresale();
        }

        if (id > 2) {
            revert InvalidId();
        }

        _mint(to, id, quantity, "");
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

    // createa a setter for erc1155 uri
}
