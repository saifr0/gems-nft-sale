// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;
import { Test, console } from "../lib/forge-std/src/Test.sol";

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "../contracts/utils/Common.sol";

import { Rewards } from "../contracts/Rewards.sol";
import { NodeNft } from "../contracts/nfts/NodeNft.sol";
import { MinerNft } from "../contracts/nfts/MinerNft.sol";

import { IMinerNft } from "../contracts/interfaces/IMinerNft.sol";
import { INodeNft } from "../contracts/interfaces/INodeNft.sol";

contract PreSaleTest is Test {
    using SafeERC20 for IERC20;

    error OwnableUnauthorizedAccount(address);

    IERC20 USDT = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);
    IERC20 USDC = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    IERC20 WETH = IERC20(0x4200000000000000000000000000000000000006);
    IERC20 WBTC = IERC20(0xcbB7C0000aB88B473b1f5aFd9ef808440eed33Bf);
    IERC20 GEMS = IERC20(0x3010ccb5419F1EF26D40a7cd3F0d707a0fa127Dc);

    address user = 0xC0FC8954c62A45c3c0a13813Bd2A10d88D70750D;
    address owner = 0x12eF0F1C99D8FD50fFd37cCd12B09Ef7f1213269;
    address funds = 0xC0FC8954c62A45c3c0a13813Bd2A10d88D70750D;

    IERC20[] tokens;
    uint256[] minerRewards;
    uint256[] nodeRewards;

    Rewards public rewardsContract;
    NodeNft public nodeNftContract;
    MinerNft public minerNftContract;

    function setUp() public {
        // -----------------------------------   ----------------------------------- //

        tokens = new IERC20[](3);
        tokens[0] = USDT;
        tokens[1] = GEMS;
        tokens[2] = USDC;

        minerRewards = new uint256[](3);
        minerRewards[0] = 5000000;
        minerRewards[1] = 3000000000000000000;
        minerRewards[2] = 2000000;

        nodeRewards = new uint256[](3);
        nodeRewards[0] = 5000000;
        nodeRewards[1] = 3000000000000000000;
        nodeRewards[2] = 2000000;

        // -----------------------------------  deal ----------------------------------- //
        deal(address(USDT), user, 2323420_000_000000 * 1e6);
        deal(address(GEMS), user, 100_000_000000 * 1e18);
        deal(address(USDC), user, 2323420_000_000000 * 1e6);

        // -----------------------------------  Contracts ----------------------------------- //
        nodeNftContract = new NodeNft(owner, "");
        minerNftContract = new MinerNft(owner, "");
        rewardsContract = new Rewards(
            funds,
            owner,
            IMinerNft(address(minerNftContract)),
            INodeNft(address(nodeNftContract)),
            tokens,
            minerRewards,
            nodeRewards
        );

        // -----------------------------------  Updating user as presale to mint ----------------------------------- //
        vm.startPrank(owner);
        nodeNftContract.updatePresaleAddress(user);
        minerNftContract.updatePresaleAddress(user);
        vm.stopPrank();
    }

    function testRewards() external {
        // -------------------------------- minting  ------------------------------------------ //
        vm.startPrank(user);
        nodeNftContract.mint(user, 4);
        vm.stopPrank();

        vm.startPrank(user);
        minerNftContract.mint(user, 0, 2);
        minerNftContract.mint(user, 1, 2);
        minerNftContract.mint(user, 2, 2);
        vm.stopPrank();

        // ------------------------------- enabling rewards  ------------------------------------------ //
        vm.startPrank(owner);
        rewardsContract.enableRewards(true);
        vm.stopPrank();

        // ------------------------------- approval  ------------------------------------------ //
        vm.startPrank(user);
        USDT.forceApprove(address(rewardsContract), USDT.balanceOf(user));
        GEMS.forceApprove(address(rewardsContract), GEMS.balanceOf(user));
        USDC.forceApprove(address(rewardsContract), USDC.balanceOf(user));
        vm.stopPrank();

        // ------------------------------- claiming miner rewards  ------------------------------------------ //
        uint256[] memory ids = new uint256[](3);
        ids[0] = 0;
        ids[1] = 1;
        ids[2] = 2;

        vm.startPrank(user);
        rewardsContract.claimMinerRewards(ids);
        vm.stopPrank();

        // ------------------------------- claiming node rewards  ------------------------------------------ //
        vm.startPrank(user);
        rewardsContract.claimNodeRewards();
        vm.stopPrank();
    }
}
