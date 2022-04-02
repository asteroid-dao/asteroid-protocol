//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ISeason {
  function genesis () external view returns (uint);

  function season_spans () external view returns (uint[] memory);
  
  function add_season_spans (uint span, uint changeAt) external;

  function season_changeAt () external view returns (uint[] memory);

  function setGenesis (uint _length) external;
  
  function season () external view returns (uint);
}
