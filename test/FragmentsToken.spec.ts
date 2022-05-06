import { expect } from './shared/expect'
import { BigNumber } from 'ethers'
import { fragmentsTokenFixture } from './shared/fixtures'
import { ethers, waffle } from 'hardhat'
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { UserInfo } from '../typechain/UserInfo'
import { UserBonus } from '../typechain/UserBonus'
import { DefxNFT } from '../typechain/DefxNFT'
import { DCoinToken } from '../typechain/DCoinToken'
import { DefxNFTFactory } from '../typechain/DefxNFTFactory'
import { FragmentsToken } from '../typechain/FragmentsToken'
import { Wallet } from 'ethers'

const createFixtureLoader = waffle.createFixtureLoader
type ThenArg<T> = T extends PromiseLike<infer U> ? U : T
describe("FragmentsToken", () => {
    let wallet: Wallet, other: Wallet
    let FragmentsTokenFixture: ThenArg<ReturnType<typeof fragmentsTokenFixture>>;
    let loadFixture: ReturnType<typeof waffle.createFixtureLoader>
    let user:SignerWithAddress;
    let user1:SignerWithAddress;
    let defxNft: DefxNFT;
    let defxNFTFactory: DefxNFTFactory;
    let fragmentsToken: FragmentsToken;
 
    let FIXED_AMOUNT_OF_CHECKINS = 10 * 10**18;
 
    before('create fixture loader', async () => {
        const [owner, owner1] = await ethers.getSigners();
        user = owner;
        user1 = owner1;
        ;[wallet, other] = await (ethers as any).getSigners()
        loadFixture = waffle.createFixtureLoader([wallet])
    })
    let userInfo: UserInfo;
    beforeEach('deploy fixture', async () => {
        let fixture = await loadFixture(fragmentsTokenFixture);
    
        defxNft = fixture.nft;
        defxNFTFactory = fixture.nftFactory;
        fragmentsToken = fixture.fragmentsToken;
        await defxNFTFactory.doMint(user.address, 18, 20); // nftId = 1
        await defxNFTFactory.doMint(other.address, 18, 20);//nftId = 2
        await defxNFTFactory.setOperator(fragmentsToken.address, true)
        await fragmentsToken.mint(user.address, BigNumber.from("12000000000000000000"));
    });

    it('constructor initializes immutables', async () => {
        expect(await fragmentsToken.nftFactory()).to.be.eq(defxNFTFactory.address);
    })
    
    it("transfer", async() =>{
        await fragmentsToken.transfer(user1.address, "1000000000000000000");
        expect(await fragmentsToken.balanceOf(user1.address)).to.be.eq("1000000000000000000");
    } )

    it("transferFrom", async() =>{
        await fragmentsToken.approve(user.address,  "1000000000000000000")
        await fragmentsToken.transferFrom(user.address ,user1.address, "1000000000000000000");
        expect(await fragmentsToken.balanceOf(user1.address)).to.be.eq("1000000000000000000");
    } )

    it("mintNft", async() =>{
       await fragmentsToken.mintNFT();
       let a = await fragmentsToken.userLastNft(user.address);
       console.info(`lastNFTId = ${a}`);
    } )
})