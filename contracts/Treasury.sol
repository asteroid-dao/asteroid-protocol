//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Envoy} from "./Envoy.sol";
import "@asteroid-dao/astero721/contracts/IASTERO721.sol";
import "hardhat/console.sol";

contract Treasury is Ownable, Envoy {
  constructor(address _registry) Envoy(_registry) {

  }
  
  function reward (uint _season) public view returns (uint) {
    return s().getUint(abi.encode("reward", _season));
  }

  function addReward (uint _season) public payable {
    require(ss().season() <= _season, "season should be greater or equal to current one.");
    s().setUint(abi.encode("reward", _season), reward(_season) + msg.value);
    safe().deposit{value: msg.value}();
  }

  function reward_vp (uint _season, address _to) public view returns (uint) {
    return s().getUint(abi.encode("reward_vp", _season, _to));
  }

  function total_reward_vp (uint _season) public view returns (uint) {
    return s().getUint(abi.encode("total_reward_vp", _season));
  }

  function getReward (uint _season) public view returns (uint){
    require(ss().season() > _season, "season hasn't ended");
    uint vp = reward_vp(_season, msg.sender);
    require(vp > 0, "no reward for the season");
    require(withdrawn(_season, msg.sender) == false, "already withdrawn");
    return reward(_season) * vp / total_reward_vp(_season);
  }
  
  function withdraw(uint _season) public payable {
    uint reward = getReward(_season);
    s().setBool(abi.encode("withdrawn", _season, msg.sender), true);
    safe().withdraw(msg.sender, reward);
  }
  
  function withdrawn (uint _season, address to) public view returns (bool) {
    return s().getBool(abi.encode("withdrawn", _season, to));    
  }
  
}
