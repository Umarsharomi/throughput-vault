pragma solidity ^0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockAsset is ERC20 {
    constructor() ERC20("Mock Asset", "MA") {
        _mint(msg.sender, 1_000_000 ether);
    }
}
