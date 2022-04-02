//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IEvents {
  function updateItem (string memory id, address token, uint token_id, string memory arweave, address owner, uint fee, uint rate, uint[] memory topics) external;
  function updateTopic (string memory id, address token, uint token_id, string memory arweave, address owner, uint fee) external;
  function tip (address from, address[2] memory tokens, uint from_amount, address[] memory to, uint[] memory to_amount, uint payback, string memory id, string memory ref, uint[] memory topics, uint[] memory topic_amounts, uint season) external;
  
}
