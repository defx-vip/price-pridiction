import { expect } from './shared/expect'
import { dcoinPricePredictionFixture } from './shared/fixtures'
import { ethers, waffle } from 'hardhat'
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { DefxNFT } from '../typechain/DefxNFT'
import { DefxNFTFactory } from '../typechain/DefxNFTFactory'
import { IERC20 } from '../typechain/IERC20'
import { DCoinToken } from '../typechain/DCoinToken'
import { DefxToken } from '../typechain/DefxToken'
import { DCoinPricePrediction } from '../typechain/DCoinPricePrediction'
import { PricePredictionReward } from '../typechain/PricePredictionReward'
import { BigNumber, Wallet } from 'ethers'

const createFixtureLoader = waffle.createFixtureLoader
type ThenArg<T> = T extends PromiseLike<infer U> ? U : T
describe("DefxNFTFactory", () => {
    let wallet: Wallet, other: Wallet
    let loadFixture: ReturnType<typeof waffle.createFixtureLoader>
    let user:SignerWithAddress;
    let defxNft: DefxNFT;
    let defxNFTFactory: DefxNFTFactory;
    let token1:DefxToken;
    let token2: DCoinToken;
    let dcoinPricePrediction: DCoinPricePrediction;
    let pricePredictionReward: PricePredictionReward;
    before('create fixture loader', async () => {
        const [owner] = await ethers.getSigners();
        user = owner;
        ;[wallet, other] = await (ethers as any).getSigners()
        loadFixture = waffle.createFixtureLoader([wallet, other])
    })

    beforeEach('deploy fixture', async () => {
        let fixture = await loadFixture(dcoinPricePredictionFixture);
        defxNft = fixture.nft;
        defxNFTFactory = fixture.nftFactory;
        dcoinPricePrediction = fixture.dcoinPricePrediction;
        pricePredictionReward = fixture.pricePredictionReward;
        token1 = fixture.dftToken;
        token2 = fixture.dcoinToken;
        await defxNFTFactory.setOperator(dcoinPricePrediction.address, true)
        await dcoinPricePrediction.genesisStartRound();
        await token2.mint(user.address, 1000000);
        await token2.approve(dcoinPricePrediction.address, 10000000);
        await pricePredictionReward.addPool(100);
        await dcoinPricePrediction.setPricePredictionReward(pricePredictionReward.address);
    });

    it('constructor initializes immutables 1', async () => {
       
    })

    it('bet one', async () => {
        await dcoinPricePrediction.betBull(1000);
    })

    

})