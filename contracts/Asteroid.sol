// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {IASTERO721} from "@asteroid-dao/astero721/contracts/IASTERO721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Envoy} from "./Envoy.sol";

contract Asteroid is Ownable, Envoy {

  constructor(address _registry) Envoy(_registry) {}

  function setId (string memory id, uint tokenId) internal {
    s().setUint(abi.encode("token_ids", id), tokenId);
  }

  function setNonce (string memory id, uint _nonce) internal {
    s().setUint(abi.encode("token_nonces", id), _nonce);
  }

  function setContract (string memory id, address _contract) internal {
    s().setAddress(abi.encode("token_contracts", id), _contract);
  }

  function setLongId (uint _tokenId, bytes32 _hash) internal {
    s().setBytes32(abi.encode("token_long_ids", _tokenId), _hash);
  }
  
  function setShortId (bytes32 _hash, string memory id) internal {
    s().setString(abi.encode("token_short_ids", _hash), id);
  }
  
  function setTopicId (string memory id, uint tokenId) internal {
    s().setUint(abi.encode("topic_token_ids", id), tokenId);
  }
  
  function setTopicNonce (string memory id, uint _nonce) internal {
    s().setUint(abi.encode("topic_token_nonces", id), _nonce);
  }
  
  function setTopicContract (string memory id, address _contract) internal {
    s().setAddress(abi.encode("topic_token_contracts", id), _contract);
  }
  
  function setTopicLongId (uint _tokenId, bytes32 _hash) internal {
    s().setBytes32(abi.encode("topic_token_long_ids", _tokenId), _hash);
  }
  
  function setTopicShortId (bytes32 _hash, string memory id) internal {
    s().setString(abi.encode("topic_token_short_ids", _hash), id);
  }
  
  /* _ids = [short_id, arweave_tx], _uints = [nonce, _rate], _extra_uints = [ratios, topics, topic_ratios]  */
  function mint (string[] memory _ids, bytes[] memory _signatures, uint[] memory _uints, bytes32 _extra, address[] memory _recipients, uint[][] memory _extra_uints) public {
    require(_extra == keccak256(abi.encode(_uints[1], _recipients, _extra_uints[0], _extra_uints[1], _extra_uints[2])), "extra parameters don't match");
    require(_uints[1] <= p().maxRate() && _uints[1] >= p().minRate(), "rate should be in range");
    require(p().nonces(_ids[0]) < _uints[0], "nonce must be greater");
    bytes32 long_id = keccak256(_signatures[0]);
    address to = ECDSA.recover(a().hashTypedDataV4(keccak256(abi.encode(keccak256("NFT(bytes signature,string arweave_tx,uint256 nonce,bytes32 extra)"), long_id, keccak256(bytes(_ids[1])), _uints[0], _extra))), _signatures[1]);
    setNonce(_ids[0], _uints[0]);
    require(p().ids(_ids[0]) == 0, "id already exists");
    require(ECDSA.recover(a().hashTypedDataV4(keccak256(abi.encode(keccak256("Article(string id)"), keccak256(bytes(_ids[0]))))), _signatures[0]) == to, "author is not signer");
    uint tokenId = a().mint(to, _ids[1]);
    setId(_ids[0], tokenId);
    setContract(_ids[0], p().token());
    setShortId(long_id, _ids[0]);
    setLongId(tokenId, long_id);
    _update(p().token(), tokenId, _uints[1], _recipients, _extra_uints, _ids, to);
  }

  function sum (uint[] memory nums) internal pure returns(uint _sum){
    for(uint i; i < nums.length; i++){
      _sum += nums[i];
    }
  }
  
  function _update (address token_contract, uint tokenId, uint _rate, address[] memory _recipients, uint[][] memory _extra_uints, string[] memory _ids, address owner) internal {
    require(_recipients.length > 0, "recipients cannot be empty");
    require(sum(_extra_uints[0]) > 0, "sum of tip ratios cannot be 0");
    require(_recipients.length == _extra_uints[0].length, "recipients and tip_ratios have to be the same length");
    require(_extra_uints[1].length == _extra_uints[2].length, "topics and topic_ratios have to be the same length");
    if(_extra_uints[1].length > 0){
      require(sum(_extra_uints[2]) > 0, "sum of topic ratios cannot be 0");
    }
    s().setUint(abi.encode("tip_rate", _ids[0]), _rate);
    s().setAddressArray(abi.encode("tip_recipients", _ids[0]), _recipients);
    s().setUintArray(abi.encode("tip_ratios", _ids[0]), _extra_uints[0]);
    s().setUintArray(abi.encode("article_topics", _ids[0]), _extra_uints[1]);
    s().setUintArray(abi.encode("article_topic_ratios", _ids[0]), _extra_uints[2]);
    e().updateItem(_ids[0], token_contract, tokenId, _ids[1], owner, 0, _rate, _extra_uints[1]);
  }

  function update (string[] memory _ids, bytes[] memory _signatures, uint[] memory _uints, bytes32 _extra, address[] memory _recipients, uint[][] memory _extra_uints) public {
    require(_extra == keccak256(abi.encode(_uints[1], _recipients, _extra_uints[0], _extra_uints[1], _extra_uints[2])), "extra parameters don't match");
    require(_uints[1] <= 10000, "rate should be less than or equal to 10000");
    require(p().nonces(_ids[0]) < _uints[0], "nonce must be greater");
    bytes32 long_id = keccak256(_signatures[0]);
    setNonce(_ids[0], _uints[0]);
    require(p().ids(_ids[0]) != 0, "id doesn't exist");
    uint tokenId = p().ids(_ids[0]);
    address token_contract = p().contracts(_ids[0]);
    address to = IASTERO721(token_contract).ownerOf(tokenId);
    require(ECDSA.recover(a().hashTypedDataV4(keccak256(abi.encode(keccak256("NFT(bytes signature,string arweave_tx,uint256 nonce,bytes32 extra)"), long_id, keccak256(bytes(_ids[1])), _uints[0], _extra))), _signatures[1]) == to, "owner is not signer");
    if(keccak256(abi.encodePacked(IASTERO721(token_contract).tokenURI(tokenId))) != keccak256(abi.encodePacked("ar://", _ids[1]))){
      IASTERO721(token_contract).setTokenURI(tokenId, _ids[1]);
    }
    _update(p().token(), tokenId, _uints[1], _recipients, _extra_uints, _ids, to);
  }
}
