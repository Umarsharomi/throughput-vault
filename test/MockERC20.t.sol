// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Test} from "forge-std/Test.sol";
import {MockERC20} from "../src/mocks/MockERC20.sol";

contract MockERC20Test is Test {
    MockERC20 token;

    address user = address(0xBEEF);

    function setUp() public {
        token = new MockERC20();
    }

    function test_Metadata() public view {
        assertEq(token.name(), "Mock Asset");
        assertEq(token.symbol(), "MAT");
        assertEq(token.decimals(), 18);
    }

    function test_Mint() public {
        token.mint(user, 100 ether);

        assertEq(token.balanceOf(user), 100 ether);
        assertEq(token.totalSupply(), 100 ether);
    }
}
