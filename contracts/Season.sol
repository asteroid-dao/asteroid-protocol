//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IStorage} from "@asteroid-dao/eternal-storage/contracts/IStorage.sol";

contract Season is Ownable {
  address public store;
  constructor(address _store) {
    store = _store;
  }

  function genesis () public view returns (uint) {
    return IStorage(store).getUint(abi.encode("config", "genesis"));
  }

  function season_spans () public view returns (uint[] memory) {
    return IStorage(store).getUintArray(abi.encode("config", "season_spans"));
  }
  
  function add_season_spans (uint span, uint changeAt) public onlyOwner {
    _add_season_spans(span, changeAt);
  }

  function _add_season_spans (uint span, uint changeAt) internal {
    uint _season = season();
    require(changeAt > _season, "change must be later than current season");
    uint[] memory _lengths = season_spans();
    uint[] memory _changes = season_changeAt();
    if(_changes.length > 0){
      require(changeAt > _changes[_changes.length - 1], "changeAt must be bigger than the last setting");      
    }
    uint[] memory lengths = new uint[](_lengths.length + 1);
    lengths[_lengths.length] = span;
    uint[] memory changes = new uint[](_changes.length + 1);
    changes[_changes.length] = changeAt;
    for(uint i = 0;i < _lengths.length; i ++){
      lengths[i] = _lengths[i];
      changes[i] = _changes[i];
    }
    IStorage(store).setUintArray(abi.encode("config", "season_spans"), lengths);
    IStorage(store).setUintArray(abi.encode("config", "season_changeAt"), changes);    
  }
  
  function season_changeAt () public view returns (uint[] memory) {
    return IStorage(store).getUintArray(abi.encode("config", "season_changeAt"));
  }

  function setGenesis (uint _length) public onlyOwner {
    require(genesis() == 0, "genesis already set");
    IStorage(store).setUint(abi.encode("config", "genesis"), block.timestamp);
    _add_season_spans(_length, 1);
  }
  
  function season () public view returns (uint) {
    uint[] memory spans = season_spans();
    uint[] memory changes = season_changeAt();
    uint _genesis = genesis();
    uint cur = _genesis;
    uint _season = 0;
    for(uint i = 0;i < spans.length; i ++){
      while(cur <= block.timestamp && (i >= spans.length - 1 || changes[i + 1] - 1 > _season)){
	cur += spans[i];
	_season += 1;
      }
    }
    return _season;
  }
  
}
