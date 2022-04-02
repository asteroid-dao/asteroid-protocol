//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@asteroid-dao/astero721/contracts/ASTERO721.sol";

contract Topics is ASTERO721 {
  constructor(string memory _name, string memory _symbol, string memory _version) ASTERO721(_name, _symbol, _version) {}
}
