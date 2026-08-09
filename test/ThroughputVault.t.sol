// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Test} from "forge-std/Test.sol";
import {ThroughputVault} from "../src/ThroughputVault.sol";

contract ThroughputVaultTest is Test {
    ThroughputVault vault;

    function setUp() public {
        vault = new ThroughputVault();
    }

    function test_Name() public view {
        assertEq(vault.name(), "Throughput Vault");
    }

    function test_Version() public view {
        assertEq(vault.version(), "0.1.0");
    }
}
