import { expect } from './shared/expect'
import { optionPoolFixture, DEFXCALLFixture} from './shared/fixtures'
import { ethers, waffle } from 'hardhat'
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers'
import { OptionPool } from '../typechain/OptionPool'
import { DefxNFT } from '../typechain/DefxNFT'
import { DefxNFTFactory } from '../typechain/DefxNFTFactory'
import { IERC20 } from '../typechain/IERC20'
import { DCoinToken } from '../typechain/DCoinToken'
import { BigNumber, Wallet } from 'ethers'
import { DefxToken } from '../typechain/DefxToken'
import {PriceCalculator} from '../typechain/PriceCalculator'
import { DEFXCALL } from '../typechain/DEFXCALL'
const nickname_max_length = 12;
const createFixtureLoader = waffle.createFixtureLoader
type ThenArg<T> = T extends PromiseLike<infer U> ? U : T
describe("OptionPool.spec", () => {
    let wallet: Wallet, other: Wallet

    let loadFixture: ReturnType<typeof waffle.createFixtureLoader>
    let user:SignerWithAddress;
    let defxNft: DefxNFT;
    let defxNFTFactory: DefxNFTFactory;
    const userNftId = 1;
    const otherNftId = 2;
    let token1:DefxToken;
    let token2: DCoinToken;
    let defxCall: DEFXCALL;
    
    before('create fixture loader', async () => {
        const [owner] = await ethers.getSigners();
        user = owner;
        ;[wallet, other] = await (ethers as any).getSigners()
        loadFixture = waffle.createFixtureLoader([wallet, other])
    })

    let optionPool: OptionPool;
    beforeEach('deploy fixture', async () => {
        let fixture = await loadFixture(optionPoolFixture);
        optionPool = fixture.optionPool;
        let defxCALLFixture = await loadFixture(DEFXCALLFixture);
        let defxCall = defxCALLFixture.defxCall;
        token1 = defxCALLFixture.token;
        token1.mint(user.address, 10000);
    });

    it('constructor initializes immutables', async () => {
        
    })

   

    

})