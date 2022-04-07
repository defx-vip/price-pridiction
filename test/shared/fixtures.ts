import { Fixture } from 'ethereum-waffle'
import { ethers } from 'hardhat'
import { DefxNFT } from '../../typechain/DefxNFT'
import { DefxNFTFactory } from '../../typechain/DefxNFTFactory'
import {UserInfo} from '../../typechain/UserInfo'
import {UserBonus} from '../../typechain/UserBonus'
import {DCoinToken} from '../../typechain/DCoinToken'
import {DefxToken} from '../../typechain/DefxToken'
import {DefxNFTPool} from '../../typechain/DefxNFTPool'
import {DEFXCALL} from '../../typechain/DEFXCALL'
import {DEFXPool} from '../../typechain/DEFXPool'
import {PriceProviderMock} from '../../typechain/PriceProviderMock'
import {DEFXStaking} from '../../typechain/DEFXStaking'
import {OptionsManager} from '../../typechain/OptionsManager'
import {PriceCalculator} from '../../typechain/PriceCalculator'
import {OptionPool} from '../../typechain/OptionPool'
import {MysteryBox} from '../../typechain/MysteryBox'
import {NFTMarket} from '../../typechain/NFTMarket'
import {PricePredictionReward} from '../../typechain/PricePredictionReward'
export const TEST_POOL_START_TIME = 1601906400
import { BigNumber } from 'ethers'

interface DCoinTokenFixture {
    token: DCoinToken
}

async function dCoinTokenFixture(): Promise<DCoinTokenFixture> {
    const classType = await ethers.getContractFactory('DCoinToken')
    const token = (await classType.deploy()) as DCoinToken
    return { token }
}

interface DefxTokenFixture {
    token: DefxToken
}

async function defxTokenFixture(): Promise<DefxTokenFixture> {
    const classType = await ethers.getContractFactory('DefxToken')
    const token = (await classType.deploy()) as DefxToken
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

export async function defxNFTFactoryFixture(): Promise<DefxNFTFactoryFixture> {
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

interface UserBonusFixture {
    userBonus: UserBonus,
    nftFactory: DefxNFTFactory,
    userInfo: UserInfo
    token: DCoinToken
    nft: DefxNFT
}

export async function userBonusFixture(): Promise<UserBonusFixture> {
    const userFixture:UserInfoFixture = await userInfoFixture();
    const userInfo = userFixture.userInfo;
    const nftFactory = userFixture.nftFactory;
    const nft = userFixture.nft;
    const tokenFixture = await dCoinTokenFixture();
    const token = tokenFixture.token;
    const classType = await ethers.getContractFactory('UserBonus')
    const userBonus = (await classType.deploy(userInfo.address, token.address)) as UserBonus
    return {token, nftFactory, userInfo, userBonus, nft};
}

interface DefxNFTPoolFixture {
    nftFactory: DefxNFTFactory,
    token1: DefxToken
    token2: DCoinToken
    nft: DefxNFT
    defxNFTPool: DefxNFTPool
}

export async function defxNFTPoolFixture (): Promise<DefxNFTPoolFixture> {

    const nftFacotryFixture :DefxNFTFactoryFixture = await defxNFTFactoryFixture();
    const nftFactory = nftFacotryFixture.nftFactory;
    const nft = nftFacotryFixture.nft;
    const tokenFixture1 = await defxTokenFixture();
    const token1 = tokenFixture1.token;

    const tokenFixture2 = await dCoinTokenFixture();
    const token2 = tokenFixture2.token;
    let dftPer = BigNumber.from("19");
    let dcoinPer = BigNumber.from("100");
    const classType = await ethers.getContractFactory('DefxNFTPool')
    const defxNFTPool = (await classType.deploy(0, dftPer, dcoinPer, token1.address, token2.address, nftFactory.address)) as DefxNFTPool
    return {defxNFTPool, nftFactory, nft, token1, token2};
}

interface PriceProviderMockFixture {
    priceProviderMock: PriceProviderMock
}

export async function priceProviderMockFixture (): Promise<PriceProviderMockFixture> { 
    const classType = await ethers.getContractFactory('PriceProviderMock')
    const priceProviderMock = (await classType.deploy(3784)) as PriceProviderMock;
    return  {priceProviderMock}
}

interface DEFXStakingFixture {
    defxToken: DefxToken
    defxStaking: DEFXStaking
} 

export async function defxStakingFixture (): Promise<DEFXStakingFixture> { 
    let defxTokenFix = await defxTokenFixture();
    let defxToken = defxTokenFix.token;
    const classType = await ethers.getContractFactory('DEFXStaking')
    const defxStaking = (await classType.deploy(defxToken.address, defxToken.address, "Test", "Test")) as DEFXStaking;
    return  {defxStaking, defxToken}
}

interface OptionsManagerFixture {
    optionsManager: OptionsManager
}

export async function optionsManagerFixture (): Promise<OptionsManagerFixture> { 
    const classType = await ethers.getContractFactory('OptionsManager')
    const optionsManager = (await classType.deploy()) as OptionsManager;
    return  {optionsManager}
}

interface DEFXCALLFixture  {
    token: DefxToken
    priceProviderMock: PriceProviderMock
    optionsManager: OptionsManager
    defxStaking: DEFXStaking
    defxCall: DEFXCALL
    priceCalculator: PriceCalculator
}

export async function defxCALLFixture (): Promise<DEFXCALLFixture> { 
    let priceProviderMockFix= await priceProviderMockFixture();
    let priceProviderMock = priceProviderMockFix.priceProviderMock;
    let optionsManagerFix = await optionsManagerFixture();
    let optionsManager = optionsManagerFix.optionsManager;
    let defxStakingFix = await defxStakingFixture();
    let defxStaking = defxStakingFix.defxStaking;
    let token = defxStakingFix.defxToken;
    const classType = await ethers.getContractFactory('DEFXCALL')
    const defxCall = (await classType.deploy(token.address, "test DEfxcall", "ETH", optionsManager.address,
    "0x9e59Ba0D8a31094e714614Fd456e9a6ABa6925fA", defxStaking.address, priceProviderMock.address,
    )) as DEFXCALL; 
    let priceCalculatorFix = await priceCalculatorFixture(defxCall);
    let priceCalculator = priceCalculatorFix.priceCalculator;
    await defxCall.setPriceCalculator(priceCalculator.address);
    return  {token, priceProviderMock, optionsManager, defxStaking, defxCall, priceCalculator}
}

interface PriceCalculatorFixture {
    priceCalculator: PriceCalculator
    priceProviderMock: PriceProviderMock
    pool: DEFXPool
}

export async function priceCalculatorFixture (pool: DEFXPool): Promise<PriceCalculatorFixture> { 
    let priceProviderMockFix= await priceProviderMockFixture();
    let priceProviderMock = priceProviderMockFix.priceProviderMock;
    const classType = await ethers.getContractFactory('PriceCalculator')
    const priceCalculator = (await classType.deploy(10000,  priceProviderMock.address,pool.address)) as PriceCalculator;
    return  {priceCalculator, priceProviderMock, pool}
}

interface OptionPoolFixture {
    token: DefxToken
    optionPool: OptionPool
    defxCall: DEFXCALL
}

export async function optionPoolFixture (): Promise<OptionPoolFixture> { 
    let defxCallFixture = await defxCALLFixture();  
    let defxCall = defxCallFixture.defxCall;
    let token = defxCallFixture.token;
    const classType = await ethers.getContractFactory('OptionPool')
    const optionPool = (await classType.deploy(token.address, 10, 0)) as OptionPool;
    return  {token, optionPool, defxCall}
}

interface MysteryBoxFixture {
    nft: DefxNFT,
    nftFactory: DefxNFTFactory
    mysteryBox:  MysteryBox,
    dftToken: DefxToken
}

export async function mysteryBoxFixture (): Promise<MysteryBoxFixture> { 
    let nftFacotryFixture = await defxNFTFactoryFixture();  
    let defxTokenFixtureObj = await defxTokenFixture();
    let dftToken = defxTokenFixtureObj.token;
    let nft = nftFacotryFixture.nft;
    let nftFactory = nftFacotryFixture.nftFactory;
    const classType = await ethers.getContractFactory('MysteryBox')
    const mysteryBox = (await classType.deploy()) as MysteryBox;
    return  {nft, nftFactory, mysteryBox, dftToken}
}

interface NFTMarketFixture {
    nftMarket: NFTMarket,
    dftToken: DefxToken,
    nft: DefxNFT,
    nftFactory: DefxNFTFactory
}

export async function nftMarketFixture (): Promise<NFTMarketFixture> { 
    let nftFacotryFixture = await defxNFTFactoryFixture();  
    let defxTokenFixtureObj = await defxTokenFixture();
    let dftToken = defxTokenFixtureObj.token;
    let nft = nftFacotryFixture.nft;
    let nftFactory = nftFacotryFixture.nftFactory;
    const classType = await ethers.getContractFactory('NFTMarket')
    const nftMarket = (await classType.deploy()) as NFTMarket;
    return  {nft, nftFactory, nftMarket, dftToken}
}

interface PricePredictionRewardFixture {
    pricePredictionReward:  PricePredictionReward,
    dftToken: DefxToken
}

export async function pricePredictionRewardFixture (): Promise<PricePredictionRewardFixture> { 
    let defxTokenFixtureObj = await defxTokenFixture();
    let dftToken = defxTokenFixtureObj.token;
    const classType = await ethers.getContractFactory('PricePredictionReward')
    const pricePredictionReward = (await classType.deploy(0, 1, dftToken.address)) as PricePredictionReward;
    return  { pricePredictionReward, dftToken}
}