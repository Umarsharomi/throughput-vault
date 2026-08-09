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

    struct WithdrawalRequest {
        address owner;
        uint256 shares;
        uint256 assets;
        bool settled;
        bool claimed;
    }

    string public constant name = "Throughput Vault";
    string public constant version = "0.4.0";

    uint256 public constant INITIAL_SHARE_PRICE = 1e18;

    address public immutable asset;
    State public state;

    uint256 public totalAssets;
    uint256 public totalShares;
    uint256 public nextRequestId;

    mapping(address => uint256) public sharesOf;
    mapping(uint256 => WithdrawalRequest) public withdrawals;

    error InvalidAsset();
    error InvalidState();
    error InvalidAmount();
    error InvalidReceiver();
    error InsufficientShares();
    error InvalidRequest();
    error AlreadySettled();
    error AlreadyClaimed();

    event Deposited(
        address indexed caller,
        address indexed receiver,
        uint256 assets,
        uint256 shares
    );

    event WithdrawalRequested(
        uint256 indexed requestId,
        address indexed owner,
        uint256 shares,
        uint256 assets
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

    function requestWithdrawal(
        uint256 shares
    ) external returns (uint256 requestId) {
        if (state != State.ACTIVE && state != State.LIMITED) {
            revert InvalidState();
        }

        if (shares == 0) {
            revert InvalidAmount();
        }

        if (sharesOf[msg.sender] < shares) {
            revert InsufficientShares();
        }

        uint256 assets = (shares * sharePrice()) / 1e18;

        sharesOf[msg.sender] -= shares;
        totalShares -= shares;

        requestId = nextRequestId;
        nextRequestId = requestId + 1;

        withdrawals[requestId] = WithdrawalRequest({
            owner: msg.sender,
            shares: shares,
            assets: assets,
            settled: false,
            claimed: false
        });

        emit WithdrawalRequested(requestId, msg.sender, shares, assets);
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
