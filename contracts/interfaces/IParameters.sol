// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
interface IParameters {
  
  function treasury () external view returns (address);

  function minAmount () external view returns (uint);

  function min_tip () external view returns(uint);

  function tip_recipients (string memory id) external view returns (address[] memory);
  
  function tip_ratios (string memory id) external view returns (uint[] memory);

  function article_topics (string memory id) external view returns (uint[] memory);

  function article_topic_ratios (string memory id) external view returns (uint[] memory);

  function tip_rate (string memory id) external view returns (uint);
  
  function token () external view returns (address);

  function topic () external view returns (address);
  
  function maxRate () external view returns (uint);

  function minRate () external view returns (uint);
  
  function ids (string memory id) external view returns (uint);

  function nonces (string memory id) external view returns (uint);
  
  function contracts (string memory id) external view returns (address);
  
  function long_ids (uint _tokenId) external view returns (bytes32);
  
  function short_ids (bytes32 _hash) external view returns (string memory);
  
  function topic_ids (string memory id) external view returns (uint);
  
  function topic_nonces (string memory id) external view returns (uint);
  
  function topic_contracts (string memory id) external view returns (address);
  
  function topic_long_ids (uint _tokenId) external view returns (bytes32);
  
  function topic_short_ids (bytes32 _hash) external view returns (string memory);

}
