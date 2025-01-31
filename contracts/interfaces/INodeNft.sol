// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

interface INodeNft {
    /// @notice Returns the balance user.
    /// @param user The address of the user
    function balanceOf(address user) external view returns (uint256);
}
