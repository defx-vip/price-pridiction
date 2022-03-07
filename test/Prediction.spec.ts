import { expect } from './shared/expect'
import { ethers } from 'hardhat'

describe("BNBPricePrediction", ()=> {
   
    it("测试获取价格", async() => {
        const DefxToken = await ethers.getContractFactory("DefxToken");
        const AggregatorV3InterfaceImpl = await ethers.getContractFactory("AggregatorV3InterfaceImpl");
        const DefxTokenFactory = await ethers.getContractFactory("DefxNFTFactory");
        const BnbPricePrediction = await ethers.getContractFactory("BnbPriceUSDTPrediction");
        //Nft部署
        const defxToken = await DefxToken.deploy();
        await defxToken.deployed();

        //NFT工厂部署
        const defxTokenFactory = await DefxTokenFactory.deploy();
        await defxTokenFactory.deployed();
        await defxTokenFactory.initialize(defxToken.address, 10000);

        //Orcle部署
        const oracleInstance = await AggregatorV3InterfaceImpl.deploy();
        await oracleInstance.deployed();

        const bnbPricePrediction = await BnbPricePrediction.deploy();
        await bnbPricePrediction.deployed();
        let price = await oracleInstance.latestRoundData();
        
        expect( price >= 1000000, "price is null");
   });
   
    
})