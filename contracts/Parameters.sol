// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "hardhat/console.sol";
import "@asteroid-dao/eternal-storage/contracts/IStorage.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Envoy} from "./Envoy.sol";

contract Parameters is Ownable, Envoy {

  constructor(address _registry) Envoy(_registry) {}

  function setTreasury (address _addr) public onlyOwner {
    s().setAddress(abi.encode("config", "treasury"), _addr);
  }
  
  function setMinAmount (uint _uint) public onlyOwner {
    s().setUint(abi.encode("config", "tip_min_amount"), _uint);
  }
  
  function treasury () public view returns (address) {
    return s().getAddress(abi.encode("config", "treasury"));
  }

  function minAmount () public view returns (uint) {
    return s().getUint(abi.encode("config", "tip_min_amount"));
  }

  function setDefaultMinTip (uint _uint) public onlyOwner {
    s().setUint(abi.encode("config", "default_min_tip"), _uint);
  }
  
  function min_tip () public view returns(uint) {
    return s().getUint(abi.encode("config", "default_min_tip"));
  }

  function setToken (address _token) public onlyOwner {
    s().setAddress(abi.encode("config", "article_token"), _token);
  }

  function setTopicToken (address _token) public onlyOwner {
    s().setAddress(abi.encode("config", "topic_token"), _token);
  }

  function setMinMaxRate (uint _min, uint _max) public onlyOwner {
    require(_max <= 10000 && _min <= 10000 && _min <= _max, "min <= max <= 1000");
    s().setUint(abi.encode("config", "min_rate"), _min);
    s().setUint(abi.encode("config", "max_rate"), _max);
  }

  function tip_recipients (string memory id) public view returns (address[] memory){
    return s().getAddressArray(abi.encode("tip_recipients", id));
  }
  
  function tip_ratios (string memory id) public view returns (uint[] memory){
    return s().getUintArray(abi.encode("tip_ratios", id));
  }

  function article_topics (string memory id) public view returns (uint[] memory){
    return s().getUintArray(abi.encode("article_topics", id));
  }

  function article_topic_ratios (string memory id) public view returns (uint[] memory){
    return s().getUintArray(abi.encode("article_topic_ratios", id));
  }

  function tip_rate (string memory id) public view returns (uint){
    return s().getUint(abi.encode("tip_rate", id));
  }
  
  function token () public view returns (address){
    return s().getAddress(abi.encode("config", "article_token"));
  }

  function topic () public view returns (address){
    return s().getAddress(abi.encode("config", "topic_token"));
  }

  function maxRate () view public returns (uint) {
    return s().getUint(abi.encode("config", "max_rate"));
  }

  function minRate () view public returns (uint) {
    return s().getUint(abi.encode("config", "min_rate"));
  }

  function ids (string memory id) public view returns (uint) {
    return s().getUint(abi.encode("token_ids", id));
  }
  
  function nonces (string memory id) public view returns (uint) {
    return s().getUint(abi.encode("token_nonces", id));
  }

  function contracts (string memory id) public view returns (address) {
    return s().getAddress(abi.encode("token_contracts", id));
  }

  function long_ids (uint _tokenId) public view returns (bytes32) {
    return s().getBytes32(abi.encode("token_long_ids", _tokenId));
  }

  function short_ids (bytes32 _hash) public view returns (string memory) {
    return s().getString(abi.encode("token_short_ids", _hash));
  }

  function topic_ids (string memory id) public view returns (uint) {
    return s().getUint(abi.encode("topic_token_ids", id));
  }

  function topic_nonces (string memory id) public view returns (uint) {
    return s().getUint(abi.encode("topic_token_nonces", id));
  }
  
  function topic_contracts (string memory id) public view returns (address) {
    return s().getAddress(abi.encode("topic_token_contracts", id));
  }

  function topic_long_ids (uint _tokenId) public view returns (bytes32) {
    return s().getBytes32(abi.encode("topic_token_long_ids", _tokenId));
  }
  
  function topic_short_ids (bytes32 _hash) public view returns (string memory) {
    return s().getString(abi.encode("topic_token_short_ids", _hash));
  }
  
  function getChainId() external view returns (uint256) {
    return block.chainid;
  }
  
  function sleep() public { }

}
