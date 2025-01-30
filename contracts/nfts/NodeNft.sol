// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import { ERC721A } from "erc721a/contracts/ERC721A.sol";
import { Ownable2Step, Ownable } from "@openzeppelin/contracts/access/Ownable2Step.sol";

import { ZeroAddress, IdenticalValue } from "../utils/Common.sol";

/// @title NodeNft contract
/// @notice Implements ERC721A nft contract
contract NodeNft is ERC721A, Ownable2Step {
    /// @notice Returns the address of the presale contract
    address public presale;

    /// @notice Returns the access info of the transfer
    bool public transferEnabled;

    /// @notice Returns the basURI of the nft
    string public baseUri;

    /// @dev Emitted when token presale contract is updated
    event PresaleUpdated(address prevAddress, address newAddress);

    /// @dev Emitted when transfer enabled is updated
    event TransferEnabled(bool enabled);

    /// @notice Thrown when caller is not presale contract
    error OnlyPresale();

    /// @notice Thrown when trying to transfer nft while restricted
    error NotAllowed();

    /// @dev Constructor
    /// @param owner The address of owner wallet
    constructor(address owner, string memory uri) ERC721A("Gems Nodes", "GNODE") Ownable(owner) {
        baseUri = uri;
    }

    /// @notice Mints nft to `to`, only callable by presale contract
    /// @param to The nft will be minted to `to`
    /// @param quantity The amount of nfts to mint
    function mint(address to, uint256 quantity) external {
        if (msg.sender != presale) {
            revert OnlyPresale();
        }

        _mint(to, quantity);
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

    /// @notice Sets the new uri
    /// @param newUri The new uri
    function setBaseURI(string memory newUri) external onlyOwner {
        baseUri = newUri;
    }

    /// @notice The function overrides existing function
    /// @param from The tokenId will be transferred from `from`
    /// @param to The tokenId will be transferred to `to`
    /// @param tokenId The token id to transfer
    function transferFrom(address from, address to, uint256 tokenId) public payable virtual override {
        if (!transferEnabled) {
            revert NotAllowed();
        }

        super.transferFrom(from, to, tokenId);
    }

    /// @notice Returns the overide uniform resource identifier (URI) for `tokenId`.
    /// @param tokenId The token id
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        if (!_exists(tokenId)) _revert(URIQueryForNonexistentToken.selector);
        return baseUri;
    }

    /// @dev The function overrides existing function
    function _baseURI() internal view override returns (string memory) {
        return baseUri;
    }
}
