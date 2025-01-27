// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

interface IClaims {
    /// @notice Sets claim amount of the leader
    /// @param to The address of the leader
    /// @param claims The claim amount of the leader
    function addClaimInfo(address[] calldata to, uint256[] calldata claims) external;
}
