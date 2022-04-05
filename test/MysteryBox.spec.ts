import { expect } from './shared/expect'
import { BigNumber } from 'ethers'
import { mysteryBoxFixture } from './shared/fixtures'
import { ethers, waffle } from 'hardhat'
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'

import { DefxNFT } from '../typechain/DefxNFT'
import { DefxNFTFactory } from '../typechain/DefxNFTFactory'
import { Wallet } from 'ethers'
import { DefxToken } from '../typechain/DefxToken'
import {MysteryBox} from '../typechain/MysteryBox'
const createFixtureLoader = waffle.createFixtureLoader
type ThenArg<T> = T extends PromiseLike<infer U> ? U : T
describe("MysteryBox", () => {
    let wallet: Wallet, other: Wallet
    let _mysteryBoxFixture: ThenArg<ReturnType<typeof mysteryBoxFixture>>;
    let loadFixture: ReturnType<typeof waffle.createFixtureLoader>
    let user:SignerWithAddress;
    let defxNft: DefxNFT;
    let defxNFTFactory: DefxNFTFactory;
    let token:DefxToken;
    let mysteryBox: MysteryBox;
    let FIXED_AMOUNT_OF_CHECKINS = 10 * 10**18;
    const userNftId = 1;
    const otherNftId = 2;
    before('create fixture loader', async () => {
        const [owner] = await ethers.getSigners();
        user = owner;
        ;[wallet, other] = await (ethers as any).getSigners()
        loadFixture = waffle.createFixtureLoader([wallet, other])
    })

    beforeEach('deploy mysteryBox', async () => {
        let fixture = await loadFixture(mysteryBoxFixture);
        defxNft = fixture.nft;
        defxNFTFactory = fixture.nftFactory;
        token = fixture.dftToken;
        defxNFTFactory = fixture.nftFactory;
        mysteryBox = fixture.mysteryBox;
        await mysteryBox.addBoxFactory("test1", defxNFTFactory.address, 1000, user.address, token.address, 100);
        await defxNFTFactory.setOperator(mysteryBox.address, true);
        await token.mint(user.address, 10000000);
        await token.approve(mysteryBox.address, 1000000);
    });

    it('constructor initializes immutables', async () => {
        
    })
    
    it('buy mysteryBox one ', async () => { 
       await mysteryBox.buy(1, 2);
       expect(await mysteryBox.balanceOf(user.address)).to.be.eq(2);
    })

    it('buy mysteryBox tow', async () => { 
        await mysteryBox.buy(1, 2);
        await mysteryBox.buy(1, 2);
        expect(await mysteryBox.balanceOf(user.address)).to.be.eq(4);
     })

     it('open mysteryBox one', async () => { 
        await mysteryBox.buy(1, 2);
        await mysteryBox.openBox(1001);
        expect(await mysteryBox.balanceOf(user.address)).to.be.eq(1);
     })

     it('open mysteryBox two', async () => { 
        await mysteryBox.buy(1, 2);
        await mysteryBox.openBox(1001);
        await mysteryBox.openBox(1002);
       expect(await mysteryBox.balanceOf(user.address)).to.be.eq(0);
     })
})