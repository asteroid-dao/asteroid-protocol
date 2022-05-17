// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ROID is ERC20 {
  constructor(uint256 initialSupply) ERC20("Asteroid", "ROID") {
    _mint(msg.sender, initialSupply);
  }
}
