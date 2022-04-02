# Asteroid Protocol

## Astar Network Mainnet Contracts

- Storage [0xa664dF5116Ccab9914207eba4C3E291910bADa44](https://blockscout.com/astar/address/0xa664dF5116Ccab9914207eba4C3E291910bADa44/transactions)

- Registry [0xe70DC845E74c1a2A686de2D4CFC9941B6D5B3D65](https://blockscout.com/astar/address/0xe70DC845E74c1a2A686de2D4CFC9941B6D5B3D65/transactions)

- Articles(ERC721) [0xdCbe2dA7578787BA356d27532ee5B7f3fFCE8EFD](https://blockscout.com/astar/token/0xdCbe2dA7578787BA356d27532ee5B7f3fFCE8EFD/token-transfers)

- Topics(ERC721) [0x4Bd310078BC05b129EcBAfb5912bbC8E66bf568E](https://blockscout.com/astar/token/0x4Bd310078BC05b129EcBAfb5912bbC8E66bf568E/token-transfers)

- Events [0xDc56766b1b00C606a2F220a10A82Bd9d424BC73D](https://blockscout.com/astar/address/0x4Bd310078BC05b129EcBAfb5912bbC8E66bf568E/token-transfers)

- Safe [0x1372F8cA344E40D067f25386eEE8e894b4e39396](https://blockscout.com/astar/address/0x1372F8cA344E40D067f25386eEE8e894b4e39396/token-transfers)

The other contracts are upgradable and often change. Contract addresses can be obtained via the `Registry` contract.

Available contract names are `storage` `registry` `articles` `topics` `events` `safe` `treasury` `asteroid` `season` `tip` `parameters` `topic`.

```solidity
interface IRegistry {

  function get(string memory _name) external view returns (address addr);

  function list() external view returns (string[] memory _strs);
  
}
```
