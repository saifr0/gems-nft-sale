// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { TokenInfo } from "../utils/Common.sol";

interface ITokenRegistry {
    /// @notice Gives us onchain price of the token
    /// @param token The address of token to get live price and normalization factor
    function getLatestPrice(IERC20 token) external view returns (TokenInfo memory);
}
