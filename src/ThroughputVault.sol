// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

contract ThroughputVault {
    enum State {
        UNINITIALIZED,
        ACTIVE,
        LIMITED,
        PAUSED,
        SETTLEMENT,
        FINALIZED
    }

    string public constant name = "Throughput Vault";
    string public constant version = "0.2.0";

    address public immutable asset;

    State public state;

    uint256 public totalAssets;
    uint256 public totalShares;

    mapping(address => uint256) public sharesOf;

    error InvalidAsset();
    error InvalidState();

    constructor(address asset_) {
        if (asset_ == address(0)) {
            revert InvalidAsset();
        }

        asset = asset_;
        state = State.ACTIVE;
    }

    function sharePrice() external view returns (uint256) {
        if (totalShares == 0) {
            return 1e18;
        }

        return (totalAssets * 1e18) / totalShares;
    }

    function setState(State newState) external {
        if (newState == State.UNINITIALIZED) {
            revert InvalidState();
        }

        state = newState;
    }
}
