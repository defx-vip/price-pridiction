import { Fixture } from 'ethereum-waffle'
import { ethers } from 'hardhat'
import { DefxNFT } from '../../typechain/DefxNFT'
import { DefxNFTFactory } from '../../typechain/DefxNFTFactory'
import {UserInfo} from '../../typechain/UserInfo'
export const TEST_POOL_START_TIME = 1601906400

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
}

async function defxNFTFactoryFixture(): Promise<DefxNFTFactoryFixture> {
    const classType = await ethers.getContractFactory('DefxNFTFactory')
    const nftFactory = (await classType.deploy()) as DefxNFTFactory
    return { nftFactory }
}

interface UserInfoFixture {
    userInfo: UserInfo,
    nftFactory: DefxNFTFactory,
    nft: DefxNFT
}

export async function userInfoFixture(): Promise<UserInfoFixture> {
    const nftFacotryFixture :DefxNFTFactoryFixture = await defxNFTFactoryFixture();
    const nftFactory = nftFacotryFixture.nftFactory;
    const nftFixture = await defxNFTFixture();
    const nft = nftFixture.nft;
    const classType = await ethers.getContractFactory('UserInfo')
    const userInfo = (await classType.deploy(nftFactory.address)) as UserInfo
    const admin_role = await nft.MINT_ROLE();
    await nft.grantRole(admin_role, nftFactory.address);
    await nftFactory.initialize(nft.address, 10000);
    return { userInfo,  nftFactory, nft}
}