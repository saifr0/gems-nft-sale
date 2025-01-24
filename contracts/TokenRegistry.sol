// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import { OwnableUpgradeable } from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

import { TokenInfo, ZeroAddress, ArrayLengthMismatch, ZeroLengthArray, IdenticalValue } from "./utils/Common.sol";

/// @title Tokens registry contract
/// @notice Implements the price feed of the tokens
contract TokenRegistry is OwnableUpgradeable {
    /// @member priceFeed The Chainlink price feed address
    /// @member normalizationFactor The normalization factor to achieve return value of 18 decimals, while calculating presale token purchases and always with different token decimals
    /// @member tolerance The pricefeed live price should be updated in tolerance time to get better price
    struct PriceFeedData {
        AggregatorV3Interface priceFeed;
        uint8 normalizationFactor;
        uint256 tolerance;
    }

    /// @notice Gives us onchain price oracle address of the token
    mapping(IERC20 => PriceFeedData) public tokenData;

    /// @dev Emitted when address of Chainlink price feed contract is added for the token
    event TokenDataAdded(IERC20 token, PriceFeedData data);

    /// @notice Thrown if the roundId of price is not updated
    error RoundIdNotUpdated();

    /// @notice Thrown if the price is not updated
    error PriceNotUpdated();

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address initialOwner) public initializer {
        __Ownable_init(initialOwner);
    }

    /// @notice Sets token price feeds and normalization factors
    /// @param tokens The addresses of the tokens
    /// @param priceFeedData Contains the price feed of the tokens, tolerance and the normalization factor
    function setTokenPriceFeed(IERC20[] memory tokens, PriceFeedData[] memory priceFeedData) external onlyOwner {
        uint256 tokensLength = tokens.length;

        if (tokensLength == 0) {
            revert ZeroLengthArray();
        }

        if (tokensLength != priceFeedData.length) {
            revert ArrayLengthMismatch();
        }

        for (uint256 i = 0; i < tokensLength; ++i) {
            PriceFeedData memory data = priceFeedData[i];
            IERC20 token = tokens[i];
            PriceFeedData memory currentPriceFeedData = tokenData[token];

            if (address(token) == address(0) || address(data.priceFeed) == address(0)) {
                revert ZeroAddress();
            }

            if (
                currentPriceFeedData.priceFeed == data.priceFeed &&
                currentPriceFeedData.normalizationFactor == data.normalizationFactor &&
                currentPriceFeedData.tolerance == data.tolerance
            ) {
                revert IdenticalValue();
            }

            emit TokenDataAdded({ token: token, data: data });
            tokenData[token] = data;
        }
    }

    /// @notice The Chainlink inherited function, give us tokens live price
    /// @param token The token address
    function getLatestPrice(IERC20 token) public view returns (TokenInfo memory) {
        PriceFeedData memory data = tokenData[token];
        TokenInfo memory tokenInfo;

        if (address(data.priceFeed) == address(0)) {
            return tokenInfo;
        }

        (uint80 roundId, /*uint80 roundID*/ int price /*uint256 startedAt*/ /*uint80 answeredInRound*/, , uint256 updatedAt, ) = /*uint256 timeStamp*/ data
            .priceFeed
            .latestRoundData();

        if (roundId == 0) {
            revert RoundIdNotUpdated();
        }

        if (updatedAt == 0 || block.timestamp - updatedAt > data.tolerance) {
            revert PriceNotUpdated();
        }

        return TokenInfo({ latestPrice: uint256(price), normalizationFactor: data.normalizationFactor });
    }

    /// @dev Reserved space for future storage variables to prevent storage conflicts
    uint256[50] private __gap;
}
