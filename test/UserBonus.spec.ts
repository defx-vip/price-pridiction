import { expect } from './shared/expect'
import { BigNumber } from 'ethers'
import { userBonusFixture } from './shared/fixtures'
import { ethers, waffle } from 'hardhat'
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { UserInfo } from '../typechain/UserInfo'
import { UserBonus } from '../typechain/UserBonus'
import { DefxNFT } from '../typechain/DefxNFT'
import { DCoinToken } from '../typechain/DCoinToken'
import { DefxNFTFactory } from '../typechain/DefxNFTFactory'
import { Wallet } from 'ethers'

const createFixtureLoader = waffle.createFixtureLoader
type ThenArg<T> = T extends PromiseLike<infer U> ? U : T
describe("UserBonus", () => {
    let wallet: Wallet, other: Wallet
    let _lucky100DailyFixture: ThenArg<ReturnType<typeof userBonusFixture>>;
    let loadFixture: ReturnType<typeof waffle.createFixtureLoader>
    let user:SignerWithAddress;
    let defxNft: DefxNFT;
    let defxNFTFactory: DefxNFTFactory;
    let lucky100Daily: UserBonus;
    let token:DCoinToken;
    let FIXED_AMOUNT_OF_CHECKINS = 10 * 10**18;
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
        let fixture = await loadFixture(userBonusFixture);
        userInfo = fixture.userInfo;
        defxNft = fixture.nft;
        defxNFTFactory = fixture.nftFactory;
        token = fixture.token;
        lucky100Daily = fixture.userBonus;
        await defxNFTFactory.doMint(user.address, 18, 20); // nftId = 1
        await defxNFTFactory.doMint(other.address, 18, 20);//nftId = 2
        await defxNFTFactory.setOperator(userInfo.address, true)
        await token.mint(lucky100Daily.address, BigNumber.from("1000000000000000000000"));
    
        expect(await defxNFTFactory.ownerOf(userNftId)).to.be.eq(user.address)
        expect(await defxNFTFactory.ownerOf(otherNftId)).to.be.eq(other.address)
    });

    it('constructor initializes immutables', async () => {
        expect(await lucky100Daily.userInfo()).to.be.eq(userInfo.address);
    })

    it('execte lucky not nft', async () => {
        return expect(lucky100Daily.excuteLucky()).to.eventually.be.rejected;
    })

    it('execte lucky', async () => {
        await userInfo.setUserNFTId(1)
        await lucky100Daily.excuteLucky()
        expect (await lucky100Daily.bonusAmounts(user.address)).to.be.gte(BigNumber.from("100000000000000000000")).lte(BigNumber.from("200000000000000000000"))
    })

    it('execte lucky not nft', async () => {
        await userInfo.setUserNFTNull();
        return expect(lucky100Daily.excuteLucky()).to.eventually.be.rejected;
    })

    it('execte checkin', async () => {
        let bonusAmount = await lucky100Daily.bonusAmounts(user.address);
        await lucky100Daily.withdrawBonus(bonusAmount);
        await lucky100Daily.checkin();
        let day = BigNumber.from(new Date().getTime()).div(1000 * 60 * 60 * 24);
        expect( await lucky100Daily.checkins(user.address, day)).to.be.eq(1);
        expect( await await lucky100Daily.bonusAmounts(user.address)).to.be.eq(BigNumber.from("10000000000000000000"));
    })

})