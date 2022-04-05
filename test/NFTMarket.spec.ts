import { expect } from './shared/expect'
import { BigNumber } from 'ethers'
import { nftMarketFixture } from './shared/fixtures'
import { ethers, waffle } from 'hardhat'
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'

import { DefxNFT } from '../typechain/DefxNFT'
import { DefxNFTFactory } from '../typechain/DefxNFTFactory'
import { Wallet } from 'ethers'
import { DefxToken } from '../typechain/DefxToken'
import {NFTMarket} from '../typechain/NFTMarket'
const createFixtureLoader = waffle.createFixtureLoader
type ThenArg<T> = T extends PromiseLike<infer U> ? U : T
describe("NFTMarket", () => {
    let wallet: Wallet, other: Wallet

    let loadFixture: ReturnType<typeof waffle.createFixtureLoader>
    let user:SignerWithAddress;
    let user2:SignerWithAddress;
    let defxNft: DefxNFT;
    let defxNFTFactory: DefxNFTFactory;
    let token:DefxToken;
    let nftMarket: NFTMarket;
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
        let fixture = await loadFixture(nftMarketFixture);
        defxNft = fixture.nft;
        defxNFTFactory = fixture.nftFactory;
        token = fixture.dftToken;
        defxNFTFactory = fixture.nftFactory;
        nftMarket = fixture.nftMarket;
        await token.mint(user2.address, 10000000);
        await token.connect(user2).approve(nftMarket.address, 1000000);
        await nftMarket.addSupportCurrency(token.address);
        await nftMarket.addSupportNft(defxNft.address);
        await nftMarket.setTipsFeeWallet(user.address);
        defxNft.setApprovalForAll(nftMarket.address, true);
        await defxNFTFactory.doMint(user.address, 1, 100);
        await defxNFTFactory.doMint(user.address, 1, 100);
    });

    it('constructor initializes immutables', async () => {
        console.info(`user = ${user.address} user2 = ${user2.address}`)
    })
    
    it('startSales one ', async () => { 
       let now  = Math.floor(new Date().getTime() / 1000);
       await nftMarket.startSales(userNftId, 1000, 950, now, 300, defxNft.address, token.address )
       expect(await defxNFTFactory.ownerOf(userNftId)).to.be.eq(nftMarket.address);
    })

    it('startSales two ', async () => { 
        let now  = Math.floor(new Date().getTime() / 1000);
        await nftMarket.startSales(userNftId, 1000, 950, now, 300, defxNft.address, token.address )
        await nftMarket.startSales(otherNftId, 1000, 950, now, 300, defxNft.address, token.address )
        expect(await defxNFTFactory.ownerOf(userNftId)).to.be.eq(nftMarket.address);
        expect(await defxNFTFactory.ownerOf(otherNftId)).to.be.eq(nftMarket.address);
     })

     it('cancelSales', async () => { 
        let now  = Math.floor(new Date().getTime() / 1000);
        await nftMarket.startSales(userNftId, 1000, 950, now, 300, defxNft.address, token.address )
        await nftMarket.cancelSales(1);
        expect(await defxNFTFactory.ownerOf(userNftId)).to.be.eq(user.address);
     })

     it('buy nft', async () => { 
        let now  = Math.floor(new Date().getTime() / 1000);
        await nftMarket.connect(user).startSales(userNftId, 1000, 950, now, 300, defxNft.address, token.address )
        await nftMarket.connect(user2).buy(1);
        expect(await defxNFTFactory.ownerOf(userNftId)).to.be.eq(user2.address);
        expect(await token.balanceOf(user.address)).to.be.gte(950).lte(1000);
     })
})