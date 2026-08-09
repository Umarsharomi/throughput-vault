// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Test} from "forge-std/Test.sol";
import {ThroughputVault} from "../src/ThroughputVault.sol";
import {MockERC20} from "../src/mocks/MockERC20.sol";

contract ThroughputVaultTest is Test {
    ThroughputVault vault;
    MockERC20 token;

    address user = address(0xBEEF);
    address attacker = address(0xBAD);

    function setUp() public {
        token = new MockERC20();
        vault = new ThroughputVault(address(token));

        token.mint(user, 1_000 ether);

        vm.startPrank(user);
        token.approve(address(vault), type(uint256).max);
        vm.stopPrank();
    }

    function depositForUser(uint256 amount) internal {
        vm.prank(user);
        vault.deposit(amount, user);
    }

    function createWithdrawal() internal returns (uint256 requestId) {
        depositForUser(100 ether);

        vm.prank(user);
        requestId = vault.requestWithdrawal(40 ether);

        vault.setState(ThroughputVault.State.SETTLEMENT);
    }

    function test_SettleWithdrawal() public {
        uint256 requestId = createWithdrawal();

        vault.settleWithdrawal(requestId);

        (
            address owner,
            uint256 shares,
            uint256 assets,
            bool settled,
            bool claimed
        ) = vault.withdrawals(requestId);

        assertEq(owner, user);
        assertEq(shares, 40 ether);
        assertEq(assets, 40 ether);
        assertTrue(settled);
        assertFalse(claimed);
    }

    function test_ClaimWithdrawal() public {
        uint256 requestId = createWithdrawal();

        vault.settleWithdrawal(requestId);

        uint256 balanceBefore = token.balanceOf(user);

        vm.prank(user);
        uint256 assets = vault.claim(requestId);

        assertEq(assets, 40 ether);
        assertEq(token.balanceOf(user), balanceBefore + 40 ether);
        assertEq(vault.totalAssets(), 60 ether);

        (, , , bool settled, bool claimed) = vault.withdrawals(requestId);

        assertTrue(settled);
        assertTrue(claimed);
    }

    function test_RevertWhenSettlingTwice() public {
        uint256 requestId = createWithdrawal();

        vault.settleWithdrawal(requestId);

        vm.expectRevert(ThroughputVault.AlreadySettled.selector);
        vault.settleWithdrawal(requestId);
    }

    function test_RevertWhenClaimingBeforeSettlement() public {
        uint256 requestId = createWithdrawal();

        vm.expectRevert(ThroughputVault.InvalidRequest.selector);

        vm.prank(user);
        vault.claim(requestId);
    }

    function test_RevertWhenUnauthorizedUserClaims() public {
        uint256 requestId = createWithdrawal();

        vault.settleWithdrawal(requestId);

        vm.expectRevert(ThroughputVault.InvalidReceiver.selector);

        vm.prank(attacker);
        vault.claim(requestId);
    }

    function test_RevertWhenClaimingTwice() public {
        uint256 requestId = createWithdrawal();

        vault.settleWithdrawal(requestId);

        vm.prank(user);
        vault.claim(requestId);

        vm.expectRevert(ThroughputVault.AlreadyClaimed.selector);

        vm.prank(user);
        vault.claim(requestId);
    }
}
