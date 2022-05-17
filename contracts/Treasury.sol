//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {Envoy} from "./Envoy.sol";
import "@asteroid-dao/astero721/contracts/IASTERO721.sol";
import "hardhat/console.sol";

contract Treasury is Ownable, Envoy {
  constructor(address _registry) Envoy(_registry) {}

  function getSeasonRewardTokens (uint _season) public view returns (address[] memory) {
    return s().getAddressArray(abi.encode("season_reward_tokens", _season));
  }
  
  function reward (uint _season) public view returns (uint) {
    return s().getUint(abi.encode("reward", _season));
  }
  
  function rewards (uint _season) public view returns (address[] memory tokens, uint[] memory amounts) {
    address[] memory _tokens = getSeasonRewardTokens(_season);
    tokens = new address[](_tokens.length + 1);
    amounts = new uint[](_tokens.length + 1);
    amounts[0] = s().getUint(abi.encode("reward", _season));
    for(uint i = 0; i < _tokens.length; i++){
      tokens[i + 1] = _tokens[i];
      amounts[i + 1] = rewardERC20(_season, _tokens[i]);
    }
  }

  function rewardERC20 (uint _season, address _token) public view returns (uint) {
    return s().getUint(abi.encode("reward", _season, _token));
  }

  function addReward (uint _season) public payable {
    require(ss().season() <= _season, "season should be greater or equal to current one.");
    s().setUint(abi.encode("reward", _season), reward(_season) + msg.value);
    safe().deposit{value: msg.value}();
  }
  
  function addRewardERC20 (uint _season, address _token, uint _amount) public {
    require(ss().season() <= _season, "season should be greater or equal to current one.");
    s().setUint(abi.encode("reward", _season, _token), rewardERC20(_season, _token) + _amount);
    IERC20(_token).transferFrom(msg.sender, address(safe()), _amount);
    address[] memory tokens = s().getAddressArray(abi.encode("season_reward_tokens", _season));
    bool exist = false;
    for(uint i = 0; i < tokens.length; i++){
      if(tokens[i] == _token){
	exist = true;
	break;
      }
    }
    if(!exist){
      address[] memory new_tokens = new address[](tokens.length + 1);
      for(uint i = 0; i < tokens.length; i++) new_tokens[i] = tokens[i];
      new_tokens[tokens.length] = _token;
      s().setAddressArray(abi.encode("season_reward_tokens", _season), new_tokens);
    }
  }
  
  function reward_vp (uint _season, address _to) public view returns (uint) {
    return s().getUint(abi.encode("reward_vp", _season, _to));
  }

  function total_reward_vp (uint _season) public view returns (uint) {
    return s().getUint(abi.encode("total_reward_vp", _season));
  }

  function getRewards (uint _season) public view returns (address[] memory tokens, uint[] memory user_amounts){
    require(ss().season() > _season, "season hasn't ended");
    uint vp = reward_vp(_season, msg.sender);
    require(vp > 0, "no reward for the season");
    require(withdrawn(_season, msg.sender) == false, "already withdrawn");
    uint[] memory amounts;
    (tokens, amounts) = rewards(_season);
    user_amounts = new uint[](tokens.length);
    uint total_vp = total_reward_vp(_season);
    for(uint i = 0; i < tokens.length; i++){
      user_amounts[i] = amounts[i] * vp / total_vp;
    }
  }
  
  function withdraw(uint _season) public payable {
    (address[] memory _tokens, uint[] memory _rewards) = getRewards(_season);
    for(uint i = 0; i < _tokens.length; i++){
      if(_rewards[i] > 0){
	if(_tokens[i] == address(0)){
	  safe().withdraw(msg.sender, _rewards[i]);
	}else{
	  safe().withdrawERC20(_tokens[i], msg.sender, _rewards[i]);
	}
      }
    }
    s().setBool(abi.encode("withdrawn", _season, msg.sender), true);
  }
  
  function withdrawn (uint _season, address to) public view returns (bool) {
    return s().getBool(abi.encode("withdrawn", _season, to));    
  }
  
}
