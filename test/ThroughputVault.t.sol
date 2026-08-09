// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Test} from "forge-std/Test.sol";
import {ThroughputVault} from "../src/ThroughputVault.sol";

contract ThroughputVaultTest is Test {
    ThroughputVault vault;

    address constant ASSET = address(0x1234);

    function setUp() public {
        vault = new ThroughputVault(ASSET);
    }

    function test_Name() public view {
        assertEq(vault.name(), "Throughput Vault");
    }

    function test_Version() public view {
        assertEq(vault.version(), "0.2.0");
    }

    function test_Asset() public view {
        assertEq(vault.asset(), ASSET);
    }

    function test_InitialStateIsActive() public view {
        assertEq(
            uint256(vault.state()),
            uint256(ThroughputVault.State.ACTIVE)
        );
    }

    function test_InitialTotalsAreZero() public view {
        assertEq(vault.totalAssets(), 0);
        assertEq(vault.totalShares(), 0);
    }

    function test_InitialSharePrice() public view {
        assertEq(vault.sharePrice(), 1e18);
    }
}
