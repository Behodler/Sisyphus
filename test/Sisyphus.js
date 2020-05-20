
const async = require('./helpers/async.js')
const expectThrow = require('./helpers/expectThrow').handle
const bigNumber = require('bignumber.js')
const test = async.test
const setup = async.setup
const sisyphus = artifacts.require('Sisyphus')
const scarcity = artifacts.require("MockScarcity")
const time = require('./helpers/time')

let primary = ""
contract('sisyphus', accounts => {
    var scarcityInstance, sisyphusInstance
    const primaryOptions = { from: accounts[0], gas: "0x6091b7" }
    const secondaryOptions = { from: accounts[1], gas: "0x6091b7" }
    setup(async () => {
        scarcityInstance = await scarcity.deployed()
        sisyphusInstance = await sisyphus.deployed()
        await scarcityInstance.mint(accounts[0], '10000000', primaryOptions)
        await scarcityInstance.mint(accounts[1], '10000000', primaryOptions)

        primary = accounts[0]
    })


    test("initial buy should not affect scarcity balance", async () => {
        const monarch = (await sisyphusInstance.CurrentMonarch.call()).toString()
        assert.equal(monarch, '0x0000000000000000000000000000000000000000')
        const buyoutBefore = (await sisyphusInstance.BuyoutAmount.call()).toString()
        const buyoutTimeBefore = new bigNumber((await sisyphusInstance.BuyoutTime.call()).toString())
        assert.equal(buyoutBefore, '0')
        const initialBlock = (await web3.eth.getBlockNumber());

        for (let blockNumber = (await web3.eth.getBlockNumber()); blockNumber <= initialBlock + 100; blockNumber = (await time.advanceBlock()));
        await sisyphusInstance.struggle(0, primaryOptions)

        const monarchAfter = (await sisyphusInstance.CurrentMonarch.call()).toString()
        assert.equal(monarchAfter, accounts[0])
        const buyoutAfter = (await sisyphusInstance.BuyoutAmount.call()).toString()
        assert.equal(buyoutAfter, '0')
        const buyoutTimeAfter = new bigNumber(((await sisyphusInstance.BuyoutTime.call()).toString()))
        assert.isTrue(buyoutTimeAfter.isGreaterThan(buyoutTimeBefore))
    })

    test("initial buy with positive amount should increase buyout while burning all", async () => {
        const buyoutBefore = (await sisyphusInstance.BuyoutAmount.call()).toString()
        assert.equal(buyoutBefore, '0')
        const initialBlock = (await web3.eth.getBlockNumber());

        const totalSupplyString = (await scarcityInstance.totalSupply.call(primaryOptions)).toString()
        const totalScarcitySupply = new bigNumber(totalSupplyString)

        for (let blockNumber = (await web3.eth.getBlockNumber()); blockNumber <= initialBlock + 100; blockNumber = (await time.advanceBlock()));
        await scarcityInstance.approve(sisyphusInstance.address, '10000000000', secondaryOptions)
        await sisyphusInstance.struggle(10000, secondaryOptions)

        const monarchAfter = (await sisyphusInstance.CurrentMonarch.call()).toString()
        assert.equal(monarchAfter, accounts[1])
        const buyoutAfter = (await sisyphusInstance.BuyoutAmount.call()).toString()
        assert.equal(buyoutAfter, '40000')

        const totalScarcitySupplyAfter = new bigNumber((await scarcityInstance.totalSupply.call(primaryOptions)).toString())
        const goforit = `before: ${totalScarcitySupply.toString()}, after: ${totalScarcitySupplyAfter.toString()}`
        assert.equal(totalScarcitySupply.minus(totalScarcitySupplyAfter).toString(), '10000', goforit)

        await scarcityInstance.approve(sisyphusInstance.address, '10000000000', secondaryOptions)
        await expectThrow(sisyphusInstance.struggle(39999, primaryOptions), 'pretender must at forward at least as much Scx as the current buyout.')

    })

})