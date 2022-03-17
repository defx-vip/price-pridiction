import { expect } from './shared/expect'
import { defxNFTPoolFixture } from './shared/fixtures'
import { ethers, waffle } from 'hardhat'
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { DefxNFTPool } from '../typechain/DefxNFTPool'
import { DefxNFT } from '../typechain/DefxNFT'
import { DefxNFTFactory } from '../typechain/DefxNFTFactory'
import { IERC20 } from '../typechain/IERC20'
import { DCoinToken } from '../typechain/DCoinToken'
import { BigNumber, Wallet } from 'ethers'

const nickname_max_length = 12;
const createFixtureLoader = waffle.createFixtureLoader
type ThenArg<T> = T extends PromiseLike<infer U> ? U : T
describe("DefxNFTPool", () => {
    let wallet: Wallet, other: Wallet
    let _defxNFTPoolFixture: ThenArg<ReturnType<typeof defxNFTPoolFixture>>;
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

    let defxNFTPool: DefxNFTPool;
    beforeEach('deploy fixture', async () => {
        let fixture = await loadFixture(defxNFTPoolFixture);
        defxNFTPool = fixture.defxNFTPool;
        defxNft = fixture.nft;
        token1 = fixture.token1;
        token2 = fixture.token2;
        defxNFTFactory = fixture.nftFactory;
        await defxNFTFactory.doMint(user.address, 18, 20); // nftId = 1
        await defxNFTFactory.doMint(other.address, 18, 20);//nftId = 2
        await defxNFTFactory.doMint(user.address, 18, 20);//nftId = 3
        await defxNFTFactory.doMint(user.address, 9, 20);//nftId = 3
        await defxNFTFactory.setOperator(defxNFTPool.address, true)
        expect(await defxNFTFactory.ownerOf(userNftId)).to.be.eq(user.address)
        expect(await defxNFTFactory.ownerOf(otherNftId)).to.be.eq(other.address)
        await token1.mint(defxNFTPool.address, BigNumber.from("1000000000000000000000000"));
        await token2.mint(defxNFTPool.address, BigNumber.from("1000000000000000000000000"));
        await token2.excludeFromFee(defxNFTPool.address);
    });

    it('constructor initializes immutables', async () => {
        expect(await defxNFTPool.nftFactory()).to.be.eq(defxNFTFactory.address);
    })

   

    it('one staking', async () => {
        let dftPer = await defxNFTPool.detToken1PerBlock();
        let dcoinPer = await defxNFTPool.detToken2PerBlock();
        await defxNFTPool.staking(userNftId);
    
        let startBlock = await ethers.provider.getBlockNumber();
        await defxNFTFactory.setOperator(defxNFTPool.address, true)
        let end = await ethers.provider.getBlockNumber();
        let pendingToken = await defxNFTPool.pendingToken(user.address);
        expect(pendingToken.pendingToken1).to.be.gte(dftPer.mul(end - startBlock).sub(1) )
        expect(pendingToken.pendingToken2).to.be.gte(dcoinPer.mul(end - startBlock).sub(1) )
        await defxNFTFactory.setOperator(defxNFTPool.address, true)
        end = await ethers.provider.getBlockNumber();
        pendingToken = await defxNFTPool.pendingToken(user.address);
        expect(pendingToken.pendingToken1).to.be.gte(dftPer.mul(end - startBlock).sub(1)  )
        expect(pendingToken.pendingToken2).to.be.gte(dcoinPer.mul(end - startBlock).sub(1)  )
    })

    it('one staking simple', async () => {
        let dftPer = await defxNFTPool.detToken1PerBlock();
        let dcoinPer = await defxNFTPool.detToken2PerBlock();
        await defxNFTPool.staking(4);
        let pendingToken = await defxNFTPool.pendingToken(user.address);
    
        
    })

    it('two taking', async () => {
        await defxNFTPool.staking(userNftId);
        let userInfo = await (defxNFTPool.userInfos(user.address));
        let nftInfo = await (defxNFTPool.nftInfos(1));
        expect(userInfo.totalPoint1).to.be.eq(19)
        expect(userInfo.totalPoint2).to.be.eq(19)
        expect(nftInfo.point1).to.be.eq(19)
        expect(nftInfo.point2).to.be.eq(19)
 
        await defxNFTPool.staking(3);
   
        expect(await token1.balanceOf(user.address)).gte(19 -1);
        expect(await token2.balanceOf(user.address)).gte(100 - 1);
        userInfo = await (defxNFTPool.userInfos(user.address));
        nftInfo = await (defxNFTPool.nftInfos(3));
        expect(userInfo.totalPoint1).to.be.eq(38)
        expect(userInfo.totalPoint2).to.be.eq(38)
        expect(nftInfo.point1).to.be.eq(19)
        expect(nftInfo.point2).to.be.eq(19)
    })

    it('unstaking', async () => {
        await defxNFTPool.staking(userNftId);
        let userInfo = await (defxNFTPool.userInfos(user.address));
        let nftInfo = await (defxNFTPool.nftInfos(1));
        expect(userInfo.totalPoint1).to.be.eq(19)
        expect(userInfo.totalPoint2).to.be.eq(19)
        expect(nftInfo.point1).to.be.eq(19)
        expect(nftInfo.point2).to.be.eq(19)
 
        await defxNFTPool.unstaking(userNftId);
   
        expect(await token1.balanceOf(user.address)).gte(19 -1);
        expect(await token2.balanceOf(user.address)).gte(100 - 1);
        userInfo = await (defxNFTPool.userInfos(user.address));
        nftInfo = await (defxNFTPool.nftInfos(1));
        expect(userInfo.totalPoint1).to.be.eq(0)
        expect(userInfo.totalPoint2).to.be.eq(0)
        expect(nftInfo.point1).to.be.eq(19)
        expect(nftInfo.point2).to.be.eq(19)
        expect(nftInfo.status).to.be.eq(false)
    })

    it('harvest', async () => {
        await defxNFTPool.staking(userNftId);
        await defxNFTFactory.setOperator(defxNFTPool.address, true)
        let pendingToken = await defxNFTPool.pendingToken(user.address);
        console.info(`pendingToken1 = ${pendingToken.pendingToken1}`)
        console.info(`pendingToken2 = ${pendingToken.pendingToken2}`)
        await defxNFTPool.harvest();
        expect(await token1.balanceOf(user.address)).gte(19 -1);
        expect(await token2.balanceOf(user.address)).gte(100 - 1);

        pendingToken = await defxNFTPool.pendingToken(user.address);
        expect(pendingToken.pendingToken1).to.be.eq(0)
        expect(pendingToken.pendingToken2).to.be.eq(0)
    })

})