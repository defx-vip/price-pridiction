import { expect } from './shared/expect'
import { ethers } from 'hardhat'

describe("Greeter", () => {
    it("Should greeting once  it's changed", async function()  {
        const Greeter = await ethers.getContractFactory("Greeter");
        const greeter = await Greeter.deploy("Hello , world!");
        await greeter.deployed();
        const setGreetingTx = await greeter.setGreeting("Hola, mundo!");
        await setGreetingTx.wait();
        expect(await greeter.greet()).to.equal("Hola, mundo!");
    })
})
