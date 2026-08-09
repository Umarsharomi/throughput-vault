// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Test} from "forge-std/Test.sol";
import {ThroughputVault} from "../src/ThroughputVault.sol";
import {MockERC20} from "../src/mocks/MockERC20.sol";

contract ThroughputVaultTest is Test {
    ThroughputVault vault;
    MockERC20 token;

    address user = address(0xBEEF);

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

    function test_Deposit() public {
        depositForUser(100 ether);

        assertEq(vault.totalAssets(), 100 ether);
        assertEq(vault.totalShares(), 100 ether);
        assertEq(vault.sharesOf(user), 100 ether);
        assertEq(token.balanceOf(address(vault)), 100 ether);
    }

    function test_DepositEmitsEvent() public {
        vm.expectEmit(true, true, false, true);
        emit ThroughputVault.Deposited(user, user, 100 ether, 100 ether);

        vm.prank(user);
        vault.deposit(100 ether, user);
    }

    function test_RequestWithdrawal() public {
        depositForUser(100 ether);

        vm.prank(user);
        uint256 requestId = vault.requestWithdrawal(40 ether);

        (
            address owner,
            uint256 shares,
            uint256 assets,
            bool settled,
            bool claimed
        ) = vault.withdrawals(requestId);

        assertEq(requestId, 0);
        assertEq(owner, user);
        assertEq(shares, 40 ether);
        assertEq(assets, 40 ether);
        assertFalse(settled);
        assertFalse(claimed);

        assertEq(vault.sharesOf(user), 60 ether);
        assertEq(vault.totalShares(), 60 ether);
        assertEq(vault.totalAssets(), 100 ether);
    }

    function test_RequestWithdrawalEmitsEvent() public {
        depositForUser(100 ether);

        vm.expectEmit(true, true, false, true);
        emit ThroughputVault.WithdrawalRequested(
            0,
            user,
            40 ether,
            40 ether
        );

        vm.prank(user);
        vault.requestWithdrawal(40 ether);
    }

    function test_RevertWhenWithdrawalIsZero() public {
        depositForUser(100 ether);

        vm.expectRevert(ThroughputVault.InvalidAmount.selector);

        vm.prank(user);
        vault.requestWithdrawal(0);
    }

    function test_RevertWhenSharesAreInsufficient() public {
        depositForUser(100 ether);

        vm.expectRevert(ThroughputVault.InsufficientShares.selector);

        vm.prank(user);
        vault.requestWithdrawal(101 ether);
    }

    function test_RevertWhenWithdrawalRequestIsPaused() public {
        depositForUser(100 ether);
        vault.setState(ThroughputVault.State.PAUSED);

        vm.expectRevert(ThroughputVault.InvalidState.selector);

        vm.prank(user);
        vault.requestWithdrawal(10 ether);
    }
}
