// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import { ERC1155 } from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import { Ownable2Step, Ownable } from "@openzeppelin/contracts/access/Ownable2Step.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";

import { ZeroAddress, IdenticalValue } from "../utils/Common.sol";

/// @title MinerNft contract
/// @notice Implements ERC1155 nft contract
contract MinerNft is ERC1155, Ownable2Step {
    using Strings for uint256;
    /// @notice Returns the address of the presale contract
    address public presale;

    /// @notice Returns the access info of the transfer
    bool public transferEnabled;

    /// @dev Emitted when token presale contract is updated
    event PresaleUpdated(address prevAddress, address newAddress);

    /// @dev Emitted when transfer enabled is updated
    event TransferEnabled(bool enabled);

    /// @notice Thrown when caller is not presale contract
    error OnlyPresale();

    /// @notice Thrown when id to mint is invalid
    error InvalidId();

    /// @notice Thrown when trying to transfer nft while restricted
    error NotAllowed();

    /// @dev Constructor
    /// @param owner The address of owner wallet
    /// @param newUri The new base uri of the tokens
    constructor(address owner, string memory newUri) ERC1155(newUri) Ownable(owner) {}

    /// @notice Mints nft to `to`, only callable by presale contract
    /// @param to The nft will be minted to `to`
    /// @param id The nft id to mint
    /// @param quantity The amount of ids to mint
    function mint(address to, uint256 id, uint256 quantity) external {
        if (msg.sender != presale) {
            revert OnlyPresale();
        }

        if (id > 2) {
            revert InvalidId();
        }

        _mint(to, id, quantity, "");
    }

    /// @notice Returns the user's nfts balance
    /// @param account The address of the user
    /// @param id The nft id
    function minerNFtBalanceOf(address account, uint256 id) external view returns (uint256) {
        return balanceOf(account, id);
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

    /// @notice Enables or disables transfer
    /// @param enabled The decision to allow transfer or not
    function enableTransfer(bool enabled) external onlyOwner {
        bool oldTransferEnabled = transferEnabled;

        if (oldTransferEnabled == enabled) {
            revert IdenticalValue();
        }

        emit TransferEnabled({ enabled: enabled });

        transferEnabled = enabled;
    }

    /// @notice The function updates uri of the tokens
    /// @param newUri The new base uri of the tokens
    function setBaseUri(string memory newUri) external onlyOwner {
        _setURI(newUri);
    }

    /// @notice The function overrides existing function
    /// @param tokenId The nft token id for which base uri will be calculated
    function uri(uint256 tokenId) public view override returns (string memory) {
        string memory baseUri = super.uri(tokenId);
        return bytes(baseUri).length > 0 ? string.concat(baseUri, tokenId.toString()) : "";
    }

    /// @inheritdoc ERC1155
    /// @dev Overridden to change block transfer when restricted
    function _updateWithAcceptanceCheck(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values,
        bytes memory data
    ) internal virtual override {
        if (from != address(0) && !transferEnabled) {
            revert NotAllowed();
        }

        super._updateWithAcceptanceCheck(from, to, ids, values, data);
    }
}
