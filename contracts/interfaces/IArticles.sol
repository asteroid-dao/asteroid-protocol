//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IArticles {
  function hashTypedDataV4(bytes32 structHash) external view returns (bytes32);
}
