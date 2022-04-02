//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@asteroid-dao/address-registry/contracts/Registry.sol";

contract AddressRegistry is Registry {
  constructor(address _store, string memory _registry_name) Registry(_store, _registry_name) {}
}
