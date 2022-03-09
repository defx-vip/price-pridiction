import { expect } from './shared/expect'
import { userInfoFixture } from './shared/fixtures'
import { ethers, waffle } from 'hardhat'
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { UserInfo } from '../typechain/UserInfo'
import { DefxNFT } from '../typechain/DefxNFT'
import { DefxNFTFactory } from '../typechain/DefxNFTFactory'
import { Wallet } from 'ethers'
const nickname_max_length = 12;
const createFixtureLoader = waffle.createFixtureLoader
type ThenArg<T> = T extends PromiseLike<infer U> ? U : T
describe("UserInfo", () => {
    let wallet: Wallet, other: Wallet
    let _userInfoFixture: ThenArg<ReturnType<typeof userInfoFixture>>;
    let loadFixture: ReturnType<typeof waffle.createFixtureLoader>
    let user:SignerWithAddress;
    let defxNft: DefxNFT;
    let defxNFTFactory: DefxNFTFactory;
    const userNftId = 1;
    const otherNftId = 2;
    before('create fixture loader', async () => {
        const [owner] = await ethers.getSigners();
        user = owner;
        ;[wallet, other] = await (ethers as any).getSigners()
        loadFixture = waffle.createFixtureLoader([wallet, other])
    })
    let userInfo: UserInfo;
    beforeEach('deploy fixture', async () => {
        let fixture = await loadFixture(userInfoFixture);
        userInfo = fixture.userInfo;
        defxNft = fixture.nft;
        defxNFTFactory = fixture.nftFactory;
        await defxNFTFactory.doMint(user.address, 18, 20); // nftId = 1
        await defxNFTFactory.doMint(other.address, 18, 20);//nftId = 2
        await defxNFTFactory.doMint(user.address, 18, 20);//nftId = 3
        await defxNFTFactory.setOperator(userInfo.address, true)
        expect(await defxNFTFactory.ownerOf(userNftId)).to.be.eq(user.address)
        expect(await defxNFTFactory.ownerOf(otherNftId)).to.be.eq(other.address)
    });

    it('constructor initializes immutables', async () => {
        expect(await userInfo.nftFactory()).to.be.eq(defxNFTFactory.address);
    })

    it('set my Nft', async () => {
      await userInfo.setUserInfo(1, "xxxx");
      expect( (await userInfo.data(user.address)).nftId).to.be.eq(1);
      expect( (await userInfo.data(user.address)).nickname).to.be.eq("xxxx");
      expect( await defxNft.ownerOf(userNftId)).to.be.eq(defxNFTFactory.address);
    })
    it('set copy my Nft', async () => {
        await userInfo.setUserInfo(1, "xxxx");
        await userInfo.setUserInfo(1, "xxxxaaa");
        await userInfo.setUserInfo(1, "xxxxaaa");
        await userInfo.setUserInfo(3, "xxxx");
      })
    it('set two Nft', async () => {
        await userInfo.setUserInfo(3, "xxxx");
        expect( await defxNft.ownerOf(1)).to.be.eq(user.address);
    })

    it('set my NftNull', async () => {
        await userInfo.setUserNFTNull();
        expect( await defxNft.ownerOf(1)).to.be.eq(user.address);
    })

    

    it('set not my Nft', async () => {
       // await userInfo.setUserNFTId(2); 
      return expect(userInfo.setUserNFTId(2)).to.eventually.be.rejected;
    })

    it('set nickname', async () => {
       userInfo.setUserNickname("111111111");
       expect( (await userInfo.data(user.address)).nickname).to.be.eq("111111111");
    })

     it('set max length nickname', async () => {
        let a:string = "";
        for(let i = 0; i <= nickname_max_length; i++) {
            a += "x";
        }
        return  expect(userInfo.setUserNickname(a)).to.eventually.be.rejected;
    })
   
})