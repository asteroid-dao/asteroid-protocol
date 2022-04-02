//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "hardhat/console.sol";

contract Events is AccessControlEnumerable {
  bytes32 public constant EMITTER_ROLE = keccak256("EMITTER_ROLE");

  event UpdateItem (string id, address token, uint token_id, string arweave, address indexed owner, uint fee, uint rate, uint[] topics);
  event UpdateTopic (string id, address token, uint token_id, string arweave, address indexed owner, uint fee);
  event Tip(address indexed from, address[2] tokens, uint from_amount, address[] to, uint[] to_amounts, uint payback, string id, string ref, uint[] topics, uint[] topic_amounts, uint indexed season);
  
  constructor() {
      _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
      _setupRole(EMITTER_ROLE, _msgSender());
  }
  function updateItem (string memory id, address token, uint token_id, string memory arweave, address owner, uint fee, uint rate, uint[] memory topics) public onlyRole(EMITTER_ROLE) {
    emit UpdateItem(id, token, token_id, arweave, owner, fee, rate, topics);
  }
  function updateTopic (string memory id, address token, uint token_id, string memory arweave, address owner, uint fee) public onlyRole(EMITTER_ROLE) {
    emit UpdateTopic(id, token, token_id, arweave, owner, fee);
  }

  function tip (address from, address[2] memory tokens, uint from_amount, address[] memory to, uint[] memory to_amounts, uint payback, string memory id, string memory ref, uint[] memory topics, uint[] memory amounts, uint season) public onlyRole(EMITTER_ROLE) {
    emit Tip(from, tokens, from_amount, to, to_amounts, payback, id, ref, topics, amounts, season);
  }
  
}
