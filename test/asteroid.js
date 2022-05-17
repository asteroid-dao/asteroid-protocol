const { expect } = require("chai")
const B = require("big.js")
const { ethers } = require("hardhat")
const { map, splitEvery } = require("ramda")
const { nanoid } = require("nanoid")
const {
  from18,
  to18,
  a,
  b,
  deploy,
  deployJSON,
  isErr,
} = require("../lib/utils")
const ethSigUtil = require("eth-sig-util")
const Wallet = require("ethereumjs-wallet").default

const EIP712Domain = [
  { name: "name", type: "string" },
  { name: "version", type: "string" },
  { name: "chainId", type: "uint256" },
  { name: "verifyingContract", type: "address" },
]

const sleep = sec =>
  new Promise(ret => {
    setTimeout(() => {
      ret()
    }, 1000 * sec)
  })

describe("Asteroid Protocol", function () {
  let p, p2, p3, p4, p5
  const name = "Asteroid Articles"
  const name_topics = "Asteroid Topics"
  const version = "1"
  const anEthersProvider = new ethers.providers.Web3Provider(network.provider)
  let storage,
    registry,
    articles,
    topics,
    tip,
    asteroid,
    topic,
    chainId,
    treasury,
    season,
    safe,
    events,
    parameters,
    tavp,
    roid,
    token

  beforeEach(async () => {
    ;[p, p2, p3, p4, p5] = await ethers.getSigners()
    roid = await deploy("ROID", to18(1000000000))
    token = await deploy("ROID", to18(1000000000))
    storage = await deploy("Storage")
    registry = await deploy("Registry", a(storage), "addresses")
    parameters = await deploy("Parameters", a(registry))
    articles = await deploy("Articles", name, "ASTEROID_ARTICLES", version)
    topics = await deploy("Topics", name_topics, "ASTEROID_TOPICS", version)
    tip = await deploy("Tip", a(registry))
    asteroid = await deploy("Asteroid", a(registry))
    topic = await deploy("Topic", a(registry))
    season = await deploy("Season", a(storage))
    treasury = await deploy("Treasury", a(registry))
    safe = await deploy("Safe")
    events = await deploy("Events")
    tavp = await deploy("TAVP", a(registry))

    chainId = (await parameters.getChainId()).toNumber()
    await events.grantRole(await events.EMITTER_ROLE(), a(asteroid))
    await events.grantRole(await events.EMITTER_ROLE(), a(topic))
    await events.grantRole(await events.EMITTER_ROLE(), a(tip))
    await storage.grantRole(await storage.EDITOR_ROLE(), a(tip))
    await articles.grantRole(await articles.MINTER_ROLE(), a(asteroid))
    await topics.grantRole(await topics.MINTER_ROLE(), a(topic))
    await storage.grantRole(await storage.EDITOR_ROLE(), a(asteroid))
    await storage.grantRole(await storage.EDITOR_ROLE(), a(topic))
    await storage.grantRole(await storage.EDITOR_ROLE(), a(treasury))
    await storage.grantRole(await storage.EDITOR_ROLE(), a(registry))
    await storage.grantRole(await storage.EDITOR_ROLE(), a(season))
    await storage.grantRole(await storage.EDITOR_ROLE(), a(parameters))
    await safe.grantRole(await safe.DEPOSITOR_ROLE(), a(treasury))

    await registry.add("storage", a(storage))
    await registry.add("events", a(events))
    await registry.add("articles", a(articles))
    await registry.add("topics", a(topics))
    await registry.add("tip", a(tip))
    await registry.add("asteroid", a(asteroid))
    await registry.add("topic", a(topic))
    await registry.add("season", a(season))
    await registry.add("treasury", a(treasury))
    await registry.add("safe", a(safe))
    await registry.add("parameters", a(parameters))

    await parameters.setToken(a(articles))
    await parameters.setTopicToken(a(topics))
    await parameters.setMinMaxRate(50, 2000)
    await parameters.setTreasury(a(p5))
    await parameters.setMinAmount(to18("0.1"))
    await season.setGenesis(3)
  })

  const addItem = async (
    wallet,
    _id,
    nonce,
    tx,
    topics = [],
    topic_ratios = [],
    ratios = [1, 2, 3],
    recipients = [a(p2), a(p3), a(p4)],
    uint = Math.floor(Math.random() * 19) * 100 + 50,
    update = false
  ) => {
    const message = {
      id: _id,
    }
    const domain = { name, version, chainId, verifyingContract: a(articles) }
    const data = {
      types: {
        EIP712Domain,
        Article: [{ name: "id", type: "string" }],
      },
      domain,
      primaryType: "Article",
      message,
    }
    const signature = ethSigUtil.signTypedMessage(wallet.getPrivateKey(), {
      data,
    })
    const extra = ethers.utils.keccak256(
      ethers.utils.defaultAbiCoder.encode(
        ["uint", "address[]", "uint[]", "uint[]", "uint[]"],
        [uint, recipients, ratios, topics, topic_ratios]
      )
    )
    const message2 = {
      signature,
      arweave_tx: tx,
      nonce,
      extra,
    }
    const data2 = {
      types: {
        EIP712Domain,
        NFT: [
          { name: "signature", type: "bytes" },
          { name: "arweave_tx", type: "string" },
          { name: "nonce", type: "uint256" },
          { name: "extra", type: "bytes32" },
        ],
      },
      domain,
      primaryType: "NFT",
      message: message2,
    }
    const signature2 = ethSigUtil.signTypedMessage(wallet.getPrivateKey(), {
      data: data2,
    })
    await asteroid[update ? "update" : "mint"](
      [_id, tx],
      [signature, signature2],
      [nonce, uint],
      extra,
      recipients,
      [ratios, topics, topic_ratios]
    )
  }

  const addTopic = async (wallet, _id, nonce, tx, update = false) => {
    const message = {
      id: _id,
    }
    const domain = {
      name: name_topics,
      version,
      chainId,
      verifyingContract: a(topics),
    }
    const data = {
      types: {
        EIP712Domain,
        Topic: [{ name: "id", type: "string" }],
      },
      domain,
      primaryType: "Topic",
      message,
    }
    const signature = ethSigUtil.signTypedMessage(wallet.getPrivateKey(), {
      data,
    })
    const uint = 1
    const recipients = [a(p), a(p2), a(p3)]
    const ratios = [1, 1, 1]
    const extra = ethers.utils.keccak256(
      ethers.utils.defaultAbiCoder.encode(["uint"], [uint])
    )
    const message2 = {
      signature,
      arweave_tx: tx,
      nonce,
      extra,
    }
    const data2 = {
      types: {
        EIP712Domain,
        NFT: [
          { name: "signature", type: "bytes" },
          { name: "arweave_tx", type: "string" },
          { name: "nonce", type: "uint256" },
          { name: "extra", type: "bytes32" },
        ],
      },
      domain: domain,
      primaryType: "NFT",
      message: message2,
    }
    const signature2 = ethSigUtil.signTypedMessage(wallet.getPrivateKey(), {
      data: data2,
    })
    await topic[update ? "updateTopic" : "mintTopic"](
      [_id, tx],
      [signature, signature2],
      [nonce, uint],
      extra
    )
  }

  it("Should return the right seasons", async function () {
    expect((await season.season()).toNumber()).to.equal(1)
    await parameters.sleep()
    expect((await season.season()).toNumber()).to.equal(1)
    await season.add_season_spans(1, 3)
    expect((await season.season()).toNumber()).to.equal(1)
    await parameters.sleep()
    expect((await season.season()).toNumber()).to.equal(2)
    await parameters.sleep()
    expect((await season.season()).toNumber()).to.equal(2)
    await parameters.sleep()
    expect((await season.season()).toNumber()).to.equal(2)
    await parameters.sleep()
    expect((await season.season()).toNumber()).to.equal(3)
    await parameters.sleep()
    expect((await season.season()).toNumber()).to.equal(4)
    await parameters.sleep()
    expect((await season.season()).toNumber()).to.equal(5)
  })

  it("Should split tip", async function () {
    const wallet = Wallet.generate()
    const _pwallet = new ethers.Wallet(wallet.privateKey, anEthersProvider)
    const _id = nanoid(9)
    const nonce = 1
    const tx = nanoid(40)
    await addItem(
      wallet,
      _id,
      nonce,
      tx,
      [],
      [],
      [1, 3, 6],
      [a(p2), a(p3), a(p4)],
      1000
    )
    const before2 = from18(await anEthersProvider.getBalance(a(p2)))
    const before3 = from18(await anEthersProvider.getBalance(a(p3)))
    const before4 = from18(await anEthersProvider.getBalance(a(p4)))
    await tip.tip(_id, "test", { value: to18("10") })
    expect(from18(await tip.avp(_id)) * 1).to.equal(1)
    const after2 = from18(await anEthersProvider.getBalance(a(p2)))
    const after3 = from18(await anEthersProvider.getBalance(a(p3)))
    const after4 = from18(await anEthersProvider.getBalance(a(p4)))
    expect(B(after2).minus(B(before2)).toFixed() * 1).to.equal(0.9)
    expect(B(after3).minus(B(before3)).toFixed() * 1).to.equal(2.7)
    expect(B(after4).minus(B(before4)).toFixed() * 1).to.equal(5.4)
    expect(from18(await tip.ivp(a(p))) * 1).to.equal(1)
    expect(from18(await tip.pvp(a(p2))) * 1).to.equal(0.1)
    expect(from18(await tip.pvp(a(p3))) * 1).to.equal(0.3)
    expect(from18(await tip.pvp(a(p4))) * 1).to.equal(0.6)
    expect(from18(await tip.avp(_id)) * 1).to.equal(1)
    await parameters.setDefaultMinTip(to18("1.5"))
    await tip.tip(_id, "test", { value: to18("10") })
    expect(from18(await tip.reward_vp(2, a(p2))) * 1).to.equal(0)
    expect(from18(await tip.reward_vp(2, a(p3))) * 1).to.equal(0)
    expect(from18(await tip.reward_vp(2, a(p4))) * 1).to.equal(0)
    expect(from18(await tip.total_reward_vp(2)) * 1).to.equal(0)
    expect(from18(await tip.avp(_id)) * 1).to.equal(2)
    expect(from18(await tip.tavp(2, 0, _id)) * 1).to.equal(1)
    await tip.tip(_id, "test", { value: to18("10") })
    expect(from18(await tip.reward_vp(2, a(p2))) * 1).to.equal(0.2)
    expect(from18(await tip.reward_vp(2, a(p3))) * 1).to.equal(0.6)
    expect(from18(await tip.reward_vp(2, a(p4))) * 1).to.equal(1.2)
    expect(from18(await tip.total_reward_vp(2)) * 1).to.equal(2)
    expect(from18(await tip.avp(_id)) * 1).to.equal(3)
    expect(from18(await tip.tavp(2, 0, _id)) * 1).to.equal(2)
  })

  it("Should split tip with topics", async function () {
    await season.add_season_spans(100, 2)
    const wallet = Wallet.generate()
    const _pwallet = new ethers.Wallet(wallet.privateKey, anEthersProvider)
    const _id = nanoid(9)
    const nonce = 1
    const tx = nanoid(40)
    const tx2 = nanoid(40)
    await addTopic(wallet, "one", 1, tx)
    await addTopic(wallet, "two", 2, tx)
    await addTopic(wallet, "three", 3, tx)
    await addTopic(wallet, "four", 4, tx)
    await addItem(
      wallet,
      _id,
      nonce,
      tx,
      [1, 2],
      [1, 3],
      [1, 3, 6],
      [a(p2), a(p3), a(p4)],
      1000
    )
    const _id2 = nanoid(9)
    await addItem(
      wallet,
      _id2,
      nonce,
      tx2,
      [1, 2, 3, 4],
      [1, 2, 3, 4],
      [1, 3, 6],
      [a(p2), a(p3), a(p4)],
      1000
    )
    await parameters.setDefaultMinTip(to18("0.3"))
    let tip1 = await tip.tip(_id, "test", { value: to18("10") })
    const filter = events.filters.Tip(null)

    expect(from18(await tip.reward_vp(2, a(p2))) * 1).to.equal(0.075)
    expect(from18(await tip.reward_vp(2, a(p3))) * 1).to.equal(0.225)
    expect(from18(await tip.reward_vp(2, a(p4))) * 1).to.equal(0.45)
    expect(from18(await tip.total_reward_vp(2)) * 1).to.equal(0.75)
    expect(from18(await tip.avp(_id)) * 1).to.equal(1)
    expect(from18(await tip.tavp(2, 1, _id)) * 1).to.equal(0.25)
    expect(from18(await tip.tavp(2, 2, _id)) * 1).to.equal(0.75)

    let tip2 = await tip.tip(_id, "test", { value: to18("10") })
    expect(from18(await tip.reward_vp(2, a(p2))) * 1).to.equal(0.2)
    expect(from18(await tip.reward_vp(2, a(p3))) * 1).to.equal(0.6)
    expect(from18(await tip.reward_vp(2, a(p4))) * 1).to.equal(1.2)
    expect(from18(await tip.total_reward_vp(2)) * 1).to.equal(2)
    expect(from18(await tip.avp(_id)) * 1).to.equal(2)
    expect(from18(await tip.tavp(2, 1, _id)) * 1).to.equal(0.5)
    expect(from18(await tip.tavp(2, 2, _id)) * 1).to.equal(1.5)

    let tip3 = await tip.tip(_id2, "test", { value: to18("10") })
    const _events = await events.queryFilter(filter, 0)
    const _b = n => B(n).toFixed() * 1
    for (let v of _events) {
      const _data = {
        block: v.blockNumber,
        tx: v.transactionHash,
        index: v.transactionIndex,
        from: v.args.from,
        tokens: v.args.tokens,
        from_amount: _b(v.args.from_amount),
        to: v.args.to,
        to_amounts: map(_b)(v.args.to_amounts),
        payback: _b(v.args.payback),
        id: v.args.id,
        ref: v.args.ref,
        topics: map(_b)(v.args.topics),
        topic_amounts: map(_b)(v.args.topic_amounts),
        season: _b(v.args.season),
        checked: false,
      }
    }
  })

  it("Should manage treasury", async function () {
    await season.add_season_spans(100, 2)
    await treasury.addReward(1, { value: to18(1) })
    await roid.approve(a(treasury), to18(1000000000))
    expect(from18(await treasury.reward(1)) * 1).to.equal(1)
    await token.approve(a(treasury), to18(1000000000))
    await treasury.addReward(2, { value: to18(2) })
    await treasury.addRewardERC20(2, a(roid), to18(100000))
    await treasury.addRewardERC20(2, a(token), to18(50000))
    expect(from18(await treasury.reward(2)) * 1).to.equal(2)
    expect(from18(await roid.balanceOf(a(safe))) * 1).to.equal(100000)
    expect(await treasury.getSeasonRewardTokens(2)).to.eql([a(roid), a(token)])
    let i = 0
    while (i < 10) {
      const wallet = Wallet.generate()
      const _pwallet = new ethers.Wallet(wallet.privateKey, anEthersProvider)
      const _id = nanoid(9)
      const nonce = i + 1
      const tx = nanoid(40)
      await p.sendTransaction({
        to: wallet.getAddressString(),
        value: to18("1"),
      })
      await addTopic(wallet, _id, nonce, tx)
      expect(await topics.tokenURI(i + 1)).to.equal(`https://arweave.net/${tx}`)
      i++
    }
    const wallet = Wallet.generate()
    const _pwallet = new ethers.Wallet(wallet.privateKey, anEthersProvider)
    const _id = nanoid(9)
    const nonce = 1
    const tx = nanoid(40)
    await addItem(wallet, _id, nonce, tx)
    await tip.tip(_id, "test", { value: to18("1") })
    i = 0
    while (i < 100) {
      await parameters.sleep()
      i++
    }
    const before = from18(await anEthersProvider.getBalance(a(p2)))
    await treasury.connect(p2).withdraw(2)
    expect(
      Math.round(
        B(await roid.balanceOf(a(p2)))
          .div(10 ** 18)
          .toFixed()
      )
    ).to.equal(16667)
    const after = from18(await anEthersProvider.getBalance(a(p2)))
    expect(Math.round((after * 1 - before * 1) * 100)).to.equal(33)
    await isErr(treasury.connect(p2).withdraw(2))
  })

  it("Should add topics", async function () {
    await season.add_season_spans(10, 2)
    let i = 0
    let stats = []
    while (i < 10) {
      const wallet = Wallet.generate()
      const _pwallet = new ethers.Wallet(wallet.privateKey, anEthersProvider)
      const _id = nanoid(9)
      const nonce = i + 1
      const tx = nanoid(40)
      await p.sendTransaction({
        to: wallet.getAddressString(),
        value: to18("1"),
      })
      await addTopic(wallet, _id, nonce, tx)
      expect(await topics.tokenURI(i + 1)).to.equal(`https://arweave.net/${tx}`)
      stats.push({ id: _id, provider: _pwallet })
      i++
    }
    i = 0
    while (i < 10) {
      const wallet = Wallet.generate()
      const _pwallet = new ethers.Wallet(wallet.privateKey, anEthersProvider)
      const _id = nanoid(9)
      const nonce = i + 1
      const tx = nanoid(40)
      await p.sendTransaction({
        to: wallet.getAddressString(),
        value: to18("1"),
      })

      await addItem(
        wallet,
        _id,
        nonce,
        tx,
        [
          Math.ceil(Math.random() * 10),
          Math.ceil(Math.random() * 10),
          Math.ceil(Math.random() * 10),
        ],
        [1, 1, 1]
      )
      expect(await articles.tokenURI(i + 1)).to.equal(
        `https://arweave.net/${tx}`
      )
      await tip.tip(_id, "test", { value: to18("0.1") })

      stats.push({ id: _id, provider: _pwallet })
      i++
    }
  })

  it("Should add articles", async function () {
    await season.add_season_spans(10, 2)
    let i = 0
    let stats = []
    while (i < 10) {
      const wallet = Wallet.generate()
      const _pwallet = new ethers.Wallet(wallet.privateKey, anEthersProvider)
      const _id = nanoid(9)
      const nonce = i + 1
      const tx = nanoid(40)
      await p.sendTransaction({
        to: wallet.getAddressString(),
        value: to18("1"),
      })
      await addItem(wallet, _id, nonce, tx)
      expect(await articles.tokenURI(i + 1)).to.equal(
        `https://arweave.net/${tx}`
      )
      await tip.tip(_id, "test", { value: to18("0.1") })
      stats.push({ id: _id, provider: _pwallet })
      i++
    }
  })
  it("Should update topics", async function () {
    await season.add_season_spans(10, 2)
    let i = 0
    let stats = []
    while (i < 10) {
      const wallet = Wallet.generate()
      const _pwallet = new ethers.Wallet(wallet.privateKey, anEthersProvider)
      const _id = nanoid(9)
      const nonce = i + 1
      const tx = nanoid(40)
      await p.sendTransaction({
        to: wallet.getAddressString(),
        value: to18("1"),
      })
      await addTopic(wallet, _id, nonce, tx)
      expect(await topics.tokenURI(i + 1)).to.equal(`https://arweave.net/${tx}`)
      const tx2 = nanoid(40)
      await addTopic(wallet, _id, nonce + 1, tx2, true)
      expect(await topics.tokenURI(i + 1)).to.equal(
        `https://arweave.net/${tx2}`
      )
      stats.push({ id: _id, provider: _pwallet })
      i++
    }
  })
})
