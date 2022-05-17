//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "hardhat/console.sol";

interface ISafe {
  function deposit() external payable;
  function withdraw(address to, uint amount) external payable;
  function withdrawERC20(address token, address to, uint amount) external;
}
