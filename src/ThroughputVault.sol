// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract ThroughputVault {
    using SafeERC20 for IERC20;

    enum State {
        UNINITIALIZED,
        ACTIVE,
        LIMITED,
        PAUSED,
        SETTLEMENT,
        FINALIZED
    }

    string public constant name = "Throughput Vault";
    string public constant version = "0.3.0";

    uint256 public constant INITIAL_SHARE_PRICE = 1e18;

    address public immutable asset;
    State public state;

    uint256 public totalAssets;
    uint256 public totalShares;

    mapping(address => uint256) public sharesOf;

    error InvalidAsset();
    error InvalidState();
    error InvalidAmount();
    error InvalidReceiver();

    event Deposited(
        address indexed caller,
        address indexed receiver,
        uint256 assets,
        uint256 shares
    );

    constructor(address asset_) {
        if (asset_ == address(0)) {
            revert InvalidAsset();
        }

        asset = asset_;
        state = State.ACTIVE;
    }

    function deposit(
        uint256 assets,
        address receiver
    ) external returns (uint256 shares) {
        if (state != State.ACTIVE && state != State.LIMITED) {
            revert InvalidState();
        }

        if (assets == 0) {
            revert InvalidAmount();
        }

        if (receiver == address(0)) {
            revert InvalidReceiver();
        }

        shares = (assets * 1e18) / sharePrice();

        if (shares == 0) {
            revert InvalidAmount();
        }

        IERC20(asset).safeTransferFrom(msg.sender, address(this), assets);

        totalAssets += assets;
        totalShares += shares;
        sharesOf[receiver] += shares;

        emit Deposited(msg.sender, receiver, assets, shares);
    }

    function sharePrice() public view returns (uint256) {
        if (totalShares == 0) {
            return INITIAL_SHARE_PRICE;
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
