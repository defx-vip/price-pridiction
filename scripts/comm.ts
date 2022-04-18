import { ethers} from 'hardhat'
import { BigNumber } from 'ethers'
const nftFactoryAddress = "0x429bd7860a45E928F9A52Cc32f891190b25c830d";
const erc20 = "0x9E0F035628Ce4F5e02ddd14dEa2F7bd92B2A9152";
const add = "0x1425401856048e01c53b3adCE86d3ee9919a7345";
const nftAddress = "0xEe4A39bf41355c2F1546d4a4FFCa0C808dF32095";
const bnbLotteryAddress = "0x0D87F4368B2106Fb200746E182de22f5B3BDB568";
async function nftFactorySetOperator() {
    let nftFactory = await ethers.getContractAt( "DefxNFTFactory", nftFactoryAddress);
    await nftFactory.setOperator("0x97c62c81978fe50ae773d489C78ed5b475DD8813", true);
    console.info(`nftFactorySetOperator: ${add} 授权成功`);
}

async function erc20Approve() {
    let defx = await ethers.getContractAt( "ERC20", erc20);
    let num = BigNumber.from("100000000000000000000")
    await defx.approve("0x9e59Ba0D8a31094e714614Fd456e9a6ABa6925fA", num) ;
  
    console.info(`erc20Approve: ${add} 授权成功`);
}

async function nftSetApprovalForAll() {
    let defx = await ethers.getContractAt( "ERC721", nftAddress);
    await defx.setApprovalForAll(add, true) ;
    let onwer = defx.isApprovedForAll()
    console.info(`nftSetApprovalForAll: ${add} 授权成功`);
}

async function byMysteryBox() {
    let mysteryBox = await ethers.getContractAt( "MysteryBox", "0xe0A45aa20412178b804E462CE6CB9f70c51e73a7");
    await mysteryBox.buy(1, 2) ;
    console.info(`byMysteryBox: 购买成功`);
}

async function openMysteryBox() {
    let mysteryBox = await ethers.getContractAt( "MysteryBox", "0xe0A45aa20412178b804E462CE6CB9f70c51e73a7");
    await mysteryBox.openBox(1001) ;
    console.info(`openMysteryBox: 开盲盒成功`);
}

async function saleNFT() {
    let now  = Math.floor(new Date().getTime() / 1000);
    let userNftId = 80;
    let num = BigNumber.from('1000000000000000000');
    let nftMarket = await ethers.getContractAt( "NFTMarket", "0x4C86978D848925a88a61ef1b7dA61574D531C1ea");
    await nftMarket.startSales(userNftId, num, 950, now, 300, nftAddress, erc20 )
}

async function mintNFT() {
    let nftFactory = await ethers.getContractAt( "DefxNFTFactory", nftFactoryAddress);
    let i = 0;
    while( i <= 10) {
        await nftFactory.doMint("0x97c62c81978fe50ae773d489C78ed5b475DD8813", 0, 10000);
        i++
    }
}

async function bnbLotteryStart() {
    let bnbLottery = await ethers.getContractAt("BNBLottery", bnbLotteryAddress);
    await bnbLottery.executeRound();
    console.info("bnbLotteryStart");
}

async function setDocinVal() {
    let DCoinPricePredictionAddress = "0xb118e213c12C0a95466f6f7860191550522f9B38";
    let dcoinPricePrediction = await ethers.getContractAt( "DCoinPricePrediction",DCoinPricePredictionAddress);
    await dcoinPricePrediction.setPricePredictionReward("0x95Ea06a66032C09A1De25326d0eeB5DE4f1B0e8f");
}
async function setBNBLotteryVal() {
    let bnbLottery = await ethers.getContractAt("BNBLottery", bnbLotteryAddress);
    //await bnbLottery.setPricePredictionReward("0x95Ea06a66032C09A1De25326d0eeB5DE4f1B0e8f");
    await bnbLottery.bet(59);
}

async function getUserInfo() {
    let bnbLottery = await ethers.getContractAt("BNBLottery", bnbLotteryAddress);
    let reward  = await bnbLottery.pricePredictionReward();
    console.info(`reward = ${reward}`)
    let pricePredictionReward = await ethers.getContractAt( "PricePredictionReward","0x95Ea06a66032C09A1De25326d0eeB5DE4f1B0e8f");
    let day_c = 60 * 60 * 24;
    let now = Math.floor(new Date().getTime() / 1000);
    let day = Math.floor(now / day_c) * day_c ;
    let user = await pricePredictionReward.getUserInfo(2, day, "0x9e59Ba0D8a31094e714614Fd456e9a6ABa6925fA");
    console.info(user)
    
}

async function setUserInfo() {
    let UserBonusAddress = "0x347EbFB3B63135Af29ba54D68FB1f6bA561CbBDA";
    let userBonus = await ethers.getContractAt( "UserBonus",UserBonusAddress);
    await userBonus.setUserInfo("0xcB4Bc901073bae6E4ef172Aca135B393dbd9Bf7E");
}

async function addPool() {
    let PricePredictionRewardAddress = "0x95Ea06a66032C09A1De25326d0eeB5DE4f1B0e8f";
    let pricePredictionReward = await ethers.getContractAt( "PricePredictionReward",PricePredictionRewardAddress);
    await pricePredictionReward.addPool(1000);
}

mintNFT()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });