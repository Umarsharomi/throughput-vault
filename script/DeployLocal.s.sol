pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {MockAsset} from "../src/MockAsset.sol";
import {ThroughputVault} from "../src/ThroughputVault.sol";

contract DeployLocalScript is Script {
    function run() external returns (MockAsset asset, ThroughputVault vault) {
        vm.startBroadcast();
        asset = new MockAsset();
        vault = new ThroughputVault(address(asset));
        vm.stopBroadcast();
    }
}
