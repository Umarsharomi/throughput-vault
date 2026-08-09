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

    function test_Deposit() public {
        vm.prank(user);

        uint256 shares = vault.deposit(100 ether, user);

        assertEq(shares, 100 ether);
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

    function test_RevertWhenDepositAmountIsZero() public {
        vm.expectRevert(ThroughputVault.InvalidAmount.selector);

        vm.prank(user);
        vault.deposit(0, user);
    }

    function test_RevertWhenReceiverIsZeroAddress() public {
        vm.expectRevert(ThroughputVault.InvalidReceiver.selector);

        vm.prank(user);
        vault.deposit(100 ether, address(0));
    }

    function test_RevertWhenPaused() public {
        vault.setState(ThroughputVault.State.PAUSED);

        vm.expectRevert(ThroughputVault.InvalidState.selector);

        vm.prank(user);
        vault.deposit(100 ether, user);
    }
}
