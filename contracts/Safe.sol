//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";

contract Safe is AccessControlEnumerable {
  bytes32 public constant DEPOSITOR_ROLE = keccak256("DEPOSITOR_ROLE");
  constructor() {
    _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    _setupRole(DEPOSITOR_ROLE, _msgSender());
  }

  function deposit() external payable onlyRole(DEPOSITOR_ROLE) { }

  function withdraw(address to, uint amount) external payable onlyRole(DEPOSITOR_ROLE) {
    payable(to).transfer(amount);
  }

}
