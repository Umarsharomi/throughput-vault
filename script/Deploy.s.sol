// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {ThroughputVault} from "../src/ThroughputVault.sol";

contract DeployScript is Script {
    function run(address asset) external returns (ThroughputVault vault) {
        vm.startBroadcast();
        vault = new ThroughputVault(asset);
        vm.stopBroadcast();
    }
}
