import { Fixture } from 'ethereum-waffle'
import { ethers } from 'hardhat'
import { DefxNFT } from '../../typechain/DefxNFT'
import { DefxNFTFactory } from '../../typechain/DefxNFTFactory'
import {UserInfo} from '../../typechain/UserInfo'
import {Lucky100Daily} from '../../typechain/Lucky100Daily'
import {DCoinToken} from '../../typechain/DCoinToken'

export const TEST_POOL_START_TIME = 1601906400

interface DCoinTokenFixture {
    token: DCoinToken
}

async function dCoinTokenFixture(): Promise<DCoinTokenFixture> {
    const classType = await ethers.getContractFactory('DCoinToken')
    const token = (await classType.deploy()) as DCoinToken
    return { token }
}

interface DefxNFTFixture {
   nft: DefxNFT
}

async function defxNFTFixture(): Promise<DefxNFTFixture> {
    const classType = await ethers.getContractFactory('DefxNFT')
    const nft = (await classType.deploy()) as DefxNFT
    return { nft }
}

interface DefxNFTFactoryFixture {
    nftFactory: DefxNFTFactory
    nft: DefxNFT
}

async function defxNFTFactoryFixture(): Promise<DefxNFTFactoryFixture> {
    const classType = await ethers.getContractFactory('DefxNFTFactory')
    const nftFactory = (await classType.deploy()) as DefxNFTFactory
    const nftFixture = await defxNFTFixture();
    const nft = nftFixture.nft;
    const admin_role = await nft.MINT_ROLE();
    await nft.grantRole(admin_role, nftFactory.address);
    await nftFactory.initialize(nft.address, 10000);
    await nft.setApprovalForAll(nftFactory.address, true)
    return { nftFactory, nft }
}

interface UserInfoFixture {
    userInfo: UserInfo,
    nftFactory: DefxNFTFactory,
    nft: DefxNFT
}

export async function userInfoFixture(): Promise<UserInfoFixture> {
    const nftFacotryFixture :DefxNFTFactoryFixture = await defxNFTFactoryFixture();
    const nftFactory = nftFacotryFixture.nftFactory;
    
    const classType = await ethers.getContractFactory('UserInfo')
    const userInfo = (await classType.deploy(nftFactory.address)) as UserInfo
    const nft = nftFacotryFixture.nft;
    return { userInfo,  nftFactory, nft}
}

interface Lucky100DailyFixture {
    lucky100Daily: Lucky100Daily,
    nftFactory: DefxNFTFactory,
    userInfo: UserInfo
    token: DCoinToken
    nft: DefxNFT
}

export async function lucky100DailyFixture(): Promise<Lucky100DailyFixture> {
    const userFixture:UserInfoFixture = await userInfoFixture();
    const userInfo = userFixture.userInfo;
    const nftFactory = userFixture.nftFactory;
    const nft = userFixture.nft;
    const tokenFixture = await dCoinTokenFixture();
    const token = tokenFixture.token;
    
    const classType = await ethers.getContractFactory('Lucky100Daily')
    const lucky100Daily = (await classType.deploy(userInfo.address, token.address)) as Lucky100Daily
    return {token, nftFactory, userInfo, lucky100Daily, nft};
}