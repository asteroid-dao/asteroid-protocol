// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@asteroid-dao/astero721/contracts/IASTERO721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Envoy} from "./Envoy.sol";

contract Topic is Ownable, Envoy {

  constructor(address _registry) Envoy(_registry) {}

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
  
  function mintTopic (string[] memory _ids, bytes[] memory _signatures, uint[] memory _uints, bytes32 _extra) public onlyOwner {
    require(_extra == keccak256(abi.encode(_uints[1])), "extra parameters don't match");
    require(p().topic_nonces(_ids[0]) < _uints[0], "nonce must be greater");
    bytes32 long_id = keccak256(_signatures[0]);
    address to = ECDSA.recover(t().hashTypedDataV4(keccak256(abi.encode(keccak256("NFT(bytes signature,string arweave_tx,uint256 nonce,bytes32 extra)"), long_id, keccak256(bytes(_ids[1])), _uints[0], _extra))), _signatures[1]);
    setTopicNonce(_ids[0], _uints[0]);
    require(p().topic_ids(_ids[0]) == 0, "id already exists");
    require(ECDSA.recover(t().hashTypedDataV4(keccak256(abi.encode(keccak256("Topic(string id)"), keccak256(bytes(_ids[0]))))), _signatures[0]) == to, "author is not signer");
    uint tokenId = t().mint(to, _ids[1]);
    setTopicId(_ids[0], tokenId);
    setTopicContract(_ids[0], p().topic());
    setTopicShortId(long_id, _ids[0]);
    setTopicLongId(tokenId, long_id);
    e().updateTopic(_ids[0], p().topic(), tokenId, _ids[1], to, 0);
  }

  function updateTopic (string[] memory _ids, bytes[] memory _signatures, uint[] memory _uints, bytes32 _extra) public {
    require(_extra == keccak256(abi.encode(_uints[1])), "extra parameters don't match");
    require(p().topic_nonces(_ids[0]) < _uints[0], "nonce must be greater");
    bytes32 long_id = keccak256(_signatures[0]);
    setTopicNonce(_ids[0], _uints[0]);
    require(p().topic_ids(_ids[0]) != 0, "id doesn't exist");
    uint tokenId = p().topic_ids(_ids[0]);
    address token_contract = p().topic_contracts(_ids[0]);
    address to = IASTERO721(token_contract).ownerOf(tokenId);
    require(ECDSA.recover(t().hashTypedDataV4(keccak256(abi.encode(keccak256("NFT(bytes signature,string arweave_tx,uint256 nonce,bytes32 extra)"), long_id, keccak256(bytes(_ids[1])), _uints[0], _extra))), _signatures[1]) == to, "author is not signer");
    setTopicId(_ids[0], tokenId);
    setTopicContract(_ids[0], p().topic());
    setTopicShortId(long_id, _ids[0]);
    setTopicLongId(tokenId, long_id);
    e().updateTopic(_ids[0], p().topic(), tokenId, _ids[1], to, 0);
  }
  
}
