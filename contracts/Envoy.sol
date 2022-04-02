//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IStorage} from "@asteroid-dao/eternal-storage/contracts/IStorage.sol";
import {IRegistry} from "@asteroid-dao/address-registry/contracts/IRegistry.sol";
import {ISeason} from "./interfaces/ISeason.sol";
import {ISafe} from "./interfaces/ISafe.sol";
import {IASTERO721} from "@asteroid-dao/astero721/contracts/IASTERO721.sol";
import {IParameters} from "./interfaces/IParameters.sol";
import {IEvents} from "./interfaces/IEvents.sol";

contract Envoy is Ownable {
  address public registry;
  
  constructor(address _registry) {
    registry = _registry;
  }

  function safe () internal view returns (ISafe _safe) {
    _safe = ISafe(IRegistry(registry).get("safe"));
  }

  function r () internal view returns (IRegistry _registry) {
    _registry = IRegistry(registry);
  }

  function p () internal view returns (IParameters _parameters) {
    _parameters = IParameters(IRegistry(registry).get("parameters"));
  }
  
  function a () internal view returns (IASTERO721 _token) {
    _token = IASTERO721(IRegistry(registry).get("articles"));
  }
  
  function t () internal view returns (IASTERO721 _token) {
    _token = IASTERO721(IRegistry(registry).get("topics"));
  }

  function s () internal view returns (IStorage _str) {
    _str = IStorage(IRegistry(registry).get("storage"));
  }

  function e () internal view returns (IEvents _events) {
    _events = IEvents(IRegistry(registry).get("events"));
  }
  
  function ss () internal view returns (ISeason _ss) {
    _ss = ISeason(IRegistry(registry).get("season"));
  }
  
}
