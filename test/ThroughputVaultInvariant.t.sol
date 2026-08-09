pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {ThroughputVault} from "../src/ThroughputVault.sol";
import {MockERC20} from "../src/mocks/MockERC20.sol";

contract ThroughputVaultInvariantTest is Test {
    ThroughputVault internal vault;
    MockERC20 internal token;

    function setUp() public {
        token = new MockERC20();
        vault = new ThroughputVault(address(token));

        targetContract(address(vault));

        bytes4[] memory selectors = new bytes4[](1);
        selectors[0] = ThroughputVault.sharePrice.selector;

        targetSelector(FuzzSelector({addr: address(vault), selectors: selectors}));
    }

    function invariant_sharePriceIsPositive() public view {
        assertGt(vault.sharePrice(), 0);
    }
}
