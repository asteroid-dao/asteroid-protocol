require("@nomiclabs/hardhat-waffle")
const secrets = require("./secrets.json")
module.exports = {
  solidity: "0.8.9",
  networks: {
    shibuya: {
      url: secrets.shibuya.url,
      accounts: [secrets.shibuya.key],
    },
    kovan: {
      url: secrets.kovan.url,
      accounts: [secrets.kovan.key],
    },
    astar: {
      url: secrets.astar.url,
      accounts: [secrets.astar.key],
    },
  },
}
