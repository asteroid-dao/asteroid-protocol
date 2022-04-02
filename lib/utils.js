const B = require("big.js")
const { expect } = require("chai")
const { ethers } = require("hardhat")
const { utils, ContractFactory } = ethers

module.exports.toNum = n => +n.toString()

module.exports.str = _str => _str.toString()

module.exports.to18 = n => utils.parseEther(B(n).toFixed())

module.exports.from18 = utils.formatEther

module.exports.to32 = utils.formatBytes32String

module.exports.from32 = utils.parseBytes32String

module.exports.UINT_MAX = B(2).pow(256).sub(1).toFixed(0)

module.exports.arr = _arr => eval(`[${_arr.toString()}]`)

module.exports.deploy = async (name, ...args) => {
  const contract = await (await ethers.getContractFactory(name)).deploy(...args)
  await contract.deployTransaction.wait()
  return contract
}

module.exports.deployJSON = async (abi, wallet, ...args) => {
  const _Contract = new ContractFactory(abi.abi, abi.bytecode, wallet)
  const contract = await _Contract.deploy(...args)
  await contract.deployTransaction.wait()
  return contract
}

module.exports.a = obj => obj.address

module.exports.b = async (contract, addr) =>
  utils.formatEther(
    await contract.balanceOf(typeof addr === "string" ? addr : addr.address)
  )

module.exports.isErr = async fn => {
  let err = false
  try {
    await fn
  } catch (e) {
    err = true
  }
  expect(err).to.be.true
}
