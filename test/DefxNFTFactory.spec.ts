import { expect } from './shared/expect'
import { defxNFTFactoryFixture } from './shared/fixtures'
import { ethers, waffle } from 'hardhat'
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'

import { DefxNFT } from '../typechain/DefxNFT'
import { DefxNFTFactory } from '../typechain/DefxNFTFactory'
import { IERC20 } from '../typechain/IERC20'
import { DCoinToken } from '../typechain/DCoinToken'
import { BigNumber, Wallet } from 'ethers'

const nickname_max_length = 12;
const createFixtureLoader = waffle.createFixtureLoader
type ThenArg<T> = T extends PromiseLike<infer U> ? U : T
describe("DefxNFTFactory", () => {
    let wallet: Wallet, other: Wallet
    let loadFixture: ReturnType<typeof waffle.createFixtureLoader>
    let user:SignerWithAddress;
    let defxNft: DefxNFT;
    let defxNFTFactory: DefxNFTFactory;
    const userNftId = 1;
    const otherNftId = 2;
    let token1:IERC20;
    let token2: DCoinToken;
    before('create fixture loader', async () => {
        const [owner] = await ethers.getSigners();
        user = owner;
        ;[wallet, other] = await (ethers as any).getSigners()
        loadFixture = waffle.createFixtureLoader([wallet, other])
    })

    beforeEach('deploy fixture', async () => {
        let fixture = await loadFixture(defxNFTFactoryFixture);
        defxNft = fixture.nft;
        defxNFTFactory = fixture.nftFactory;
        await defxNFTFactory.doMint(user.address, 18, 20); // nftId = 1
        await defxNFTFactory.doMint(user.address, 18, 20);//nftId = 2
        await defxNFTFactory.doMint(user.address, 18, 20);//nftId = 3
        await defxNFTFactory.doMint(user.address, 18, 20);//nftId = 4
        await defxNFTFactory.doMint(user.address, 18, 20);//nftId = 5
        await defxNFTFactory.doMint(user.address, 18, 20);//nftId = 6
        expect(await defxNFTFactory.ownerOf(userNftId)).to.be.eq(user.address)
        expect(await defxNFTFactory.ownerOf(otherNftId)).to.be.eq(user.address)
    });

    it('constructor initializes immutables 1', async () => {
       
    })

    it('upgradeNft one', async () => {
        let arr = [2,3,4,5,6];
        await defxNFTFactory.upgradeNft(1, arr);
        expect(await defxNft.balanceOf(user.address)).to.be.eq(1);
        let defxToken = await defxNFTFactory._aolis(1);
        console.info(`defxToken = ` + defxToken.quality)
        let upgradedLastNft = await defxNFTFactory.upgradedLastNfts(user.address);
        console.info(`upgradedLastNft = ${upgradedLastNft}`);
    })
})