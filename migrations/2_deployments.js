const MockScarcity = artifacts.require('MockScarcity')
const Sisyphus = artifacts.require('Sisyphus')
const Faucet = artifacts.require('Faucet')

const fs = require('fs')
module.exports = async function (deployer, network, accounts) {
    var mockScarcityInstance, sisyphusInstance, faucetInstance
    await deployer.deploy(Sisyphus)
    await deployer.deploy(Faucet)
    sisyphusInstance = await Sisyphus.deployed();
    faucetInstance = await Faucet.deployed()

    if (network === 'development') {
        await deployer.deploy(MockScarcity, 'MockScarcity', 'MSCX')
        mockScarcityInstance = await MockScarcity.deployed()
        const scx = lookForScarcityAddress()
        scarcityAddress = scx === '0x0' ? mockScarcityInstance.address : scx

    }
    else {
        scarcityAddress = '0xff1614C6B220b24D140e64684aAe39067A0f1CD0'
    }

    await sisyphusInstance.seed(scarcityAddress, faucetInstance.address)
    await faucetInstance.seed(scarcityAddress)
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

    fs.writeFileSync(fileName, JSON.stringify(existingObject, null, 4))
}

const lookForScarcityAddress = () => {
    const scarcityLocation = "/home/justin/weidai ecosystem/Sisyphus/scarcityAddress.txt"
    if (fs.existsSync(scarcityLocation)) {
        const address = fs.readFileSync(scarcityLocation).toString()
        fs.writeFileSync(scarcityLocation, "0x0")
        console.log('scarcity address pickup: ' + address)
        return address.trim()
    }
}
