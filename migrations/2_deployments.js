const MockScarcity = artifacts.require('MockScarcity')
const Sisyphus = artifacts.require('Sisyphus')

const fs = require('fs')
module.exports = async function (deployer, network, accounts) {
    var mockScarcityInstance, sisyphusInstance

    if (network === 'development') {
        await deployer.deploy(MockScarcity, 'MockScarcity', 'MSCX')
        mockScarcityInstance = await MockScarcity.deployed()
        scarcityAddress = mockScarcityInstance.address
    }
    else {
        scarcityAddress = '0xff1614C6B220b24D140e64684aAe39067A0f1CD0'
    }
    await deployer.deploy(Sisyphus)
    sisyphusInstance = await Sisyphus.deployed();
    await sisyphusInstance.seed(scarcityAddress)

    let addressObject = { network, address: sisyphusInstance.address }
    const fileName = 'sisyphusAddress.json'
    const existing = fs.readFileSync(fileName)
    let existingObject = []

    existingObject = JSON.parse(existing)
    let found = false;
    for (let i = 0; i < existingObject.length; i++) {
        if (existingObject[i].network == network) {
            existingObject[i] = addressObject
            found = true
        }
    }
    if (!found)
        existingObject.push(addressObject)

    fs.writeFileSync(fileName, JSON.stringify(existingObject,null,4))
}
