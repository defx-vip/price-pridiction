import { expect } from './shared/expect'
import { BigNumber } from 'ethers'
import { pricePredictionRewardFixture } from './shared/fixtures'
import { ethers, waffle } from 'hardhat'
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'

import { DefxNFT } from '../typechain/DefxNFT'
import { DefxNFTFactory } from '../typechain/DefxNFTFactory'
import { Wallet } from 'ethers'
import { DefxToken } from '../typechain/DefxToken'
import {PricePredictionReward} from '../typechain/PricePredictionReward'
const createFixtureLoader = waffle.createFixtureLoader
type ThenArg<T> = T extends PromiseLike<infer U> ? U : T
describe("PricePredictionReward", () => {
    let wallet: Wallet, other: Wallet

    let loadFixture: ReturnType<typeof waffle.createFixtureLoader>
    let user:SignerWithAddress;
    let user2:SignerWithAddress;
 
    let token:DefxToken;
    let pricePredictionReward: PricePredictionReward;
    let FIXED_AMOUNT_OF_CHECKINS = 10 * 10**18;
    const userNftId = 1;
    const otherNftId = 2;
    before('create fixture loader', async () => {
        const [owner, owner1] = await ethers.getSigners();
        user = owner;
        user2 = owner1;
        ;[wallet, other] = await (ethers as any).getSigners()
        loadFixture = waffle.createFixtureLoader([wallet, other])
    })

    beforeEach('deploy mysteryBox', async () => {
        let fixture = await loadFixture(pricePredictionRewardFixture);
     
        token = fixture.dftToken;
        pricePredictionReward = fixture.pricePredictionReward;
        await token.mint(pricePredictionReward.address, 10000000);
        await pricePredictionReward.addPool(100);
    });

    it('constructor initializes immutables', async () => {
        console.info(`user = ${user.address} user2 = ${user2.address}`)
    })
    
    it('deposit one ', async () => { 
       let day_c = 60 * 60 * 24;
       let now = Math.floor(new Date().getTime() / 1000);
       let day = Math.floor(now / day_c) * day_c ;
       await pricePredictionReward.deposit(0, user.address, 200);

       let poolDay = await pricePredictionReward.poolDayInfos(day, 0);
       expect(poolDay.totalAmount).to.be.eq(200);
       expect(poolDay.lastRewardBlock).to.be.gte(now - 20).lte(now + 20);
       expect(poolDay.accDetTokenPerShare).to.be.eq(0);

       let userInfo = await pricePredictionReward.userInfo(0 ,user.address);
       expect(userInfo.amount).to.be.eq(200);
       expect(userInfo.lastDay).to.be.eq(day);
       expect(userInfo.rewardAmount).to.be.eq(0);
       expect(userInfo.storageReward).to.be.eq(0);
        
       let userDayInfo = await pricePredictionReward.userDayInfo(day, 0 ,user.address);
       expect(userDayInfo.amount).to.be.eq(200);
       expect(userDayInfo.rewardAmount).to.be.eq(0);
       expect(userDayInfo.rewardDebt).to.be.eq(0);

       await token.mint(pricePredictionReward.address, 5000000);
       expect(await pricePredictionReward.pendingToken(0, user.address)).to.be.eq(1);

     
    })

    it('deposit two ', async () => { 
        let day_c = 60 * 60 * 24;
        let now = Math.floor(new Date().getTime() / 1000);
        let day = Math.floor(now / day_c) * day_c ;
        await pricePredictionReward.deposit(0, user.address, 100);
        await pricePredictionReward.deposit(0, user.address, 100);

        let poolDay = await pricePredictionReward.poolDayInfos(day, 0);
        expect(poolDay.totalAmount).to.be.eq(200);
        expect(poolDay.lastRewardBlock).to.be.gte(now - 20).lte(now + 20);
        expect(poolDay.accDetTokenPerShare).to.be.eq(10000000000);
 
        let userInfo = await pricePredictionReward.userInfo(0 ,user.address);
        expect(userInfo.amount).to.be.eq(200);
        expect(userInfo.lastDay).to.be.eq(day);
        expect(userInfo.rewardAmount).to.be.eq(0);
        expect(userInfo.storageReward).to.be.eq(1);
         
        let userDayInfo = await pricePredictionReward.userDayInfo(day, 0 ,user.address);
        expect(userDayInfo.amount).to.be.eq(200);
        expect(userDayInfo.rewardAmount).to.be.eq(1);
        expect(userDayInfo.rewardDebt).to.be.eq(2);
 
        await token.mint(pricePredictionReward.address, 10000000);
        expect(await pricePredictionReward.pendingToken(0, user.address)).to.be.eq(2);
     })

     it('harvest', async () => { 
        let day_c = 60 * 60 * 24;
        let now = Math.floor(new Date().getTime() / 1000);
        let day = Math.floor(now / day_c) * day_c ;
        await pricePredictionReward.deposit(0, user.address, 100);
        await pricePredictionReward.deposit(0, user.address, 100);
        await pricePredictionReward.harvest(0);

        let userInfo = await pricePredictionReward.userInfo(0 ,user.address);
        expect(userInfo.amount).to.be.eq(200);
        expect(userInfo.lastDay).to.be.eq(day);
        expect(userInfo.rewardAmount).to.be.eq(2);
        expect(userInfo.storageReward).to.be.eq(0);
        expect(await token.balanceOf(user.address)).to.be.eq(2)

        let userDayInfo = await pricePredictionReward.userDayInfo(day, 0 ,user.address);
        expect(userDayInfo.amount).to.be.eq(200);
        expect(userDayInfo.rewardAmount).to.be.eq(2);
        expect(userDayInfo.rewardDebt).to.be.eq(3);
     })

     it('buy nft', async () => { 
       
     })
})