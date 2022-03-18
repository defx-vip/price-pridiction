import { expect } from './shared/expect'
import { optionPoolFixture} from './shared/fixtures'
import { ethers, waffle } from 'hardhat'
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { OptionPool } from '../typechain/OptionPool'
import { DefxNFT } from '../typechain/DefxNFT'
import { DefxNFTFactory } from '../typechain/DefxNFTFactory'
import { IERC20 } from '../typechain/IERC20'
import { DCoinToken } from '../typechain/DCoinToken'
import { BigNumber, Wallet } from 'ethers'
import { DefxToken } from '../typechain/DefxToken'
import {PriceCalculator} from '../typechain/PriceCalculator'
import { DEFXCALL } from '../typechain/DEFXCALL'
const nickname_max_length = 12;
const createFixtureLoader = waffle.createFixtureLoader
type ThenArg<T> = T extends PromiseLike<infer U> ? U : T
describe("OptionPool.spec", () => {
    let wallet: Wallet, other: Wallet

    let loadFixture: ReturnType<typeof waffle.createFixtureLoader>
    let user:SignerWithAddress;
    let defxNft: DefxNFT;
    let defxNFTFactory: DefxNFTFactory;
    const userNftId = 1;
    const otherNftId = 2;
    let token1:DefxToken;
    let token2: DCoinToken;
    let defxCall: DEFXCALL;
    let priceCalculator: PriceCalculator
    before('create fixture loader', async () => {
        const [owner] = await ethers.getSigners();
        user = owner;
        ;[wallet, other] = await (ethers as any).getSigners()
        loadFixture = waffle.createFixtureLoader([wallet, other])
    })

    let optionPool: OptionPool;
    beforeEach('deploy fixture', async () => {
        let fixture = await loadFixture(optionPoolFixture);
        optionPool = fixture.optionPool;
        token1 = fixture.token;
        defxCall = fixture.defxCall;
        await token1.mint(user.address, 100000);
        await token1.mint(optionPool.address, 20);
        await token1.approve(defxCall.address, 20000);
        await defxCall.setApprovalForAll(optionPool.address, true)
        await defxCall.provideFrom(user.address, 10000, false, 0)
        await defxCall.provideFrom(user.address, 10000, false, 0)
  
   
        await optionPool.addPool(100, defxCall.address, true, "ETH_PUT")
        expect(await optionPool.poolLength()).to.be.eq(1);
        expect(await optionPool.totalAllocPoint()).to.eq(100)
     
    });

    it('constructor initializes immutables', async () => {
      
    })

    it('staking one ', async () => { 
        await optionPool.staking(0, 1)
        let userInfo = await optionPool.userInfo(0, user.address);
        let pool = await optionPool.getPool(0);
        expect(pool.totalAmount).to.be.eq(10000)
        expect(userInfo.amount).to.be.eq(10000)
    })
    
    it('staking tow ', async () => { 
        await optionPool.staking(0, 0)
        let userInfo = await optionPool.userInfo(0, user.address);
        expect(userInfo.amount).to.be.eq(10000)
        let pool = await optionPool.getPool(0);
        expect(pool.totalAmount).to.be.eq(10000)
        await optionPool.staking(0, 1)
        userInfo = await optionPool.userInfo(0, user.address);
        expect(userInfo.amount).to.be.eq(20000)
        pool = await optionPool.getPool(0);
        expect(pool.totalAmount).to.be.eq(20000)
    })

    it('harvest ', async () => { 
        await optionPool.staking(0, 0)
        await optionPool.harvest(0)
        expect( await token1.balanceOf(user.address)).to.be.eq(80010)
    })
    
    it('unstaking one ', async () => { 
        await optionPool.staking(0, 0)
        await optionPool.updatePool(0);
        await optionPool.unstaking(0, 0)
        expect(await defxCall.ownerOf(1)).to.be.eq(user.address);
    })

})