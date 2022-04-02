//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Envoy} from "./Envoy.sol";
import {IRegistry} from "@asteroid-dao/address-registry/contracts/IRegistry.sol";
import "@asteroid-dao/astero721/contracts/IASTERO721.sol";
import "hardhat/console.sol";

contract Tip is Ownable, Envoy {
  
  constructor(address _registry) Envoy(_registry) {}
  
  function _calcFees (uint amount, uint payback) internal pure returns(uint tx_fee){
    tx_fee = amount * payback / 10000;
  }
  function sum (uint[] memory nums) internal pure returns(uint _sum){
    for(uint i; i < nums.length; i++){
      _sum += nums[i];
    }
  }
  
  function ivp (address from) public view returns (uint) {
    return s().getUint(abi.encode("ivp", from));    
  }

  function pvp (address to) public view returns (uint) {
    return s().getUint(abi.encode("pvp", to));
  }

  function avp (string memory id) public view returns (uint) {
    return s().getUint(abi.encode("avp", id));    
  }

  function tvp (uint _season, uint _topic) public view returns (uint) {
    return s().getUint(abi.encode("tvp", _season, _topic));    
  }

  function tavp (uint _season, uint _topic, string memory id) public view returns (uint) {
    return s().getUint(abi.encode("tavp", _season, _topic, id));    
  }

  function valid (uint _season, uint _topic, string memory id) public view returns (bool) {
    return s().getBool(abi.encode("valid", _season, _topic, id));    
  }

  function reward_vp (uint _season, address _to) public view returns (uint) {
    return s().getUint(abi.encode("reward_vp", _season, _to));
  }

  function total_reward_vp (uint _season) public view returns (uint) {
    return s().getUint(abi.encode("total_reward_vp", _season));
  }
  
  function emitTip(uint amount, uint tx_fee, string memory id, string memory ref) internal {
    address to = IASTERO721(p().contracts(id)).ownerOf(p().ids(id));
    uint[] memory _topics = new uint[](1);
    _topics[0] = 0;
    uint[] memory _amounts = new uint[](1);
    _amounts[0] = tx_fee;
    address[] memory _tos = new address[](1);
    _tos[0] = to;
    uint[] memory _to_amounts = new uint[](1);
    _to_amounts[0] = amount;
    e().tip(msg.sender, [address(0), address(0)], amount, _tos, _to_amounts, tx_fee, id, ref, _topics, _amounts, ss().season());
  }

  // u = [0: _topic, 1: _ratio, 2: _sum, 3: tx_fee, 4: _tvp]
  function _checkTopic (string memory id, uint[5] memory u, bool isLast) internal returns (uint plus, bool toValid, uint _tavp, bool _valid) {
    uint season = ss().season();
    if(u[1] > 0){
      _valid = valid(season, u[0], id);
      plus = isLast ? (u[3] - u[4]) : u[3] * u[1] / u[2];
      _tavp = tavp(season, u[0], id);
      s().setUint(abi.encode("tvp", season, u[0]), tvp(season, u[0]) + plus);
      s().setUint(abi.encode("tavp", season, u[0], id), _tavp + plus);
      if(plus + _tavp >= p().min_tip()){
	if(_valid == false){
	  toValid = true;
	  s().setBool(abi.encode("valid", season, u[0], id), true);
	}
	_valid = true;
      }
    }
  }

  function _split (uint[] memory arr, uint total_ratio, uint amount) internal pure returns (uint[] memory vals) {
    vals = new uint[](arr.length);
    uint _sum = 0;
    for(uint i; i < arr.length; i++){
      uint plus = i == arr.length - 1 ? (amount - _sum) : amount * arr[i] / total_ratio;
      vals[i] = plus;
      _sum += plus;
    } 
  }
  
  // u = [0: payback, 1: tx_fee, 2: _topic_sum, 3: _tvp, 4: plus, 5: _tip, 6: _sum, 7: sent, 8: vp, 9: season, 10: vp_sum, 11: _tavp]
  function tip (string memory id, string memory ref) public payable {
    uint[] memory u = new uint[](12);
    u[9] = ss().season();
    require(ss().genesis() > 0, "genesis not set");
    u[0] = s().getUint(abi.encode("tip_rate", id));
    require(u[0] <= 10000, "payback must be equal to or less than 10000");
    require(p().minAmount() <= msg.value, "amount too small");
    u[1] = _calcFees(msg.value, u[0]);
    payable(p().treasury()).transfer(u[1]);
    uint[] memory _topics = s().getUintArray(abi.encode("article_topics", id));
    uint[] memory _topic_ratios = s().getUintArray(abi.encode("article_topic_ratios", id));
    u[2] = sum(_topic_ratios);
    bool toValid;
    bool _valid;
    address[] memory recipients = s().getAddressArray(abi.encode("tip_recipients", id));
    uint[] memory tip_ratios = s().getUintArray(abi.encode("tip_ratios", id));
    uint[] memory vps = new uint[](recipients.length);
    u[5] = msg.value - u[1];
    u[6] = sum(tip_ratios);
    if(u[2] == 0){
      (u[4], toValid, u[11], _valid) = _checkTopic(id, [0, 1, 1, u[1], u[3]], true);
      if(_valid){
	uint[] memory _tvps = _split(tip_ratios, u[6], u[4] + (toValid ? u[11] : 0));
	for(uint i2; i2 < _tvps.length; i2++) vps[i2] += _tvps[i2];
      }
    }else{
      for(uint i = 0;i < _topics.length; i++){
	require(IASTERO721(p().topic()).ownerOf(_topics[i]) != address(0), "topic doesn't exist");
	(u[4], toValid, u[11], _valid) = _checkTopic(id, [_topics[i], _topic_ratios[i], u[2], u[1], u[3]], i == _topics.length - 1);
	u[3] += u[4];
	if(_valid){
	  uint[] memory _tvps = _split(tip_ratios, u[6], u[4] + (toValid ? u[11] : 0));
	  for(uint i2; i2 < _tvps.length; i2++) vps[i2] += _tvps[i2];
	}
      }
    }
    
    s().setUint(abi.encode("avp", id), avp(id) + u[1]);
    for(uint i; i < recipients.length; i++){
      require(msg.sender != recipients[i], "you cannot tip yourself");
      uint _sent = i == recipients.length - 1 ? (u[5] - u[7]) : u[5] * tip_ratios[i] / u[6];
      uint _vp = i == recipients.length - 1 ? (u[1] - u[8]) : u[1] * tip_ratios[i] / u[6];
      u[7] += _sent;
      u[8] += _vp;
      s().setUint(abi.encode("ivp", msg.sender), ivp(msg.sender) + _vp);
      s().setUint(abi.encode("pvp", recipients[i]), pvp(recipients[i]) + _vp);
      payable(recipients[i]).transfer(_sent);
    }
    
    for(uint i = 0;i < vps.length; i++){
      if(vps[i] > 0){
	s().setUint(abi.encode("reward_vp", u[9], recipients[i]), reward_vp(u[9], recipients[i]) + vps[i]);
	u[10] += vps[i];
      }
    }
    
    if(u[10] > 0){
      s().setUint(abi.encode("total_reward_vp", u[9]), total_reward_vp(u[9]) + u[10]);	
    }
    
    emitTip(msg.value, u[1], id, ref);
  }
}
