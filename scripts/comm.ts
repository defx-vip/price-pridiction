import { ethers} from 'hardhat'
import { BigNumber } from 'ethers'
const nftFactoryAddress = "0x8Fe97A7c1aDC4892df11c437f08eD29DC5ea4320";
const erc20 = "0x9E0F035628Ce4F5e02ddd14dEa2F7bd92B2A9152";
const add = "0x1425401856048e01c53b3adCE86d3ee9919a7345";
const nftAddress = "0xEe4A39bf41355c2F1546d4a4FFCa0C808dF32095";
const bnbLotteryAddress = "0xf15549caaFf3504f3D5Bc4A566b33508E56b7b5e";

async function nftFactorySetOperator() {
    let nftFactory = await ethers.getContractAt( "DefxNFTFactory", nftFactoryAddress);
    await nftFactory.setOperator("0xf15549caaFf3504f3D5Bc4A566b33508E56b7b5e", true);
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
    let a = await bnbLottery.pricePredictionReward();
    console.info(a);
    //let b = await bnbLottery.nftFactory();
    await bnbLottery.executeRound();
    //await bnbLottery.genesisStartRound();
    //console.info(b);
    console.info("bnbLotteryStart");
}

async function setDocinVal() {
    let DCoinPricePredictionAddress = "0x7967048f6F67d159C97180e806a39581f9e847d1";
    let dcoinPricePrediction = await ethers.getContractAt( "DCoinPricePrediction",DCoinPricePredictionAddress);
 
    await dcoinPricePrediction.setPricePredictionReward("0x95Ea06a66032C09A1De25326d0eeB5DE4f1B0e8f");
    await dcoinPricePrediction.setNftMinimumAmount(0);
}

async function setBNBLotteryVal() {
    let bnbLottery = await ethers.getContractAt("BNBLottery", bnbLotteryAddress);
    await bnbLottery.setPricePredictionReward("0x95Ea06a66032C09A1De25326d0eeB5DE4f1B0e8f");
    let num = BigNumber.from("100000000000000000000")
    await bnbLottery.setRoundRewardAmount(num);
}



async function setUserInfo() {
    let UserBonusAddress = "0x9E47914FbC820ca303F80D1c0834108c7F06daC6";
    let userBonus = await ethers.getContractAt( "UserBonus",UserBonusAddress);
    await userBonus.setUserInfo("0x95c3AbBA43561ef7E7345129753a342766F38212");
}

async function addPool() {
    let PricePredictionRewardAddress = "0x95Ea06a66032C09A1De25326d0eeB5DE4f1B0e8f";
    let pricePredictionReward = await ethers.getContractAt( "PricePredictionReward",PricePredictionRewardAddress);
    await pricePredictionReward.addPool(1000);
}

async function addSupportNft() {
    let addr = "0x9f403180eb3d987bADA089163927BF0d2d423c3B";
    let nftMarket = await ethers.getContractAt( "NFTMarket",addr);
    await nftMarket.addSupportNft("0x1425401856048e01c53b3adCE86d3ee9919a7345");
}

async function getDefxToken() {
    let nftFactory = await ethers.getContractAt( "DefxNFTFactory", nftFactoryAddress);
    let a = await nftFactory._aolis(165);
    console.info(a);
}

async function getUserInfo() {
    let userInfo = await ethers.getContractAt( "DefxNFTPool", "0xfA5b022C8e0e9533ac204AE71df95BE7789379a4");
    let a = await userInfo.nftFactory();
    console.info(a);
}

async function setPredictionBonusSharePool() {
    let bnbPriceUSDTPrediction = await ethers.getContractAt( "BnbPriceUSDTPrediction", "0xc0a10CF722b16D28aA963eD89f7DA915B63f4725");
    let bonusSharePool = "0x2AAB2ACA4598893dc826191EAE01ff0099bAFA52";
    await bnbPriceUSDTPrediction.setBonusSharePool(bonusSharePool);
    await bnbPriceUSDTPrediction.approveToStakingAddress()
}
async function setSharerAddress() {
    let tokenBonusSharePool = await ethers.getContractAt( "TokenBonusSharePool", "0x2AAB2ACA4598893dc826191EAE01ff0099bAFA52");
    let owner = await tokenBonusSharePool.owner();
    console.info(owner)
    await tokenBonusSharePool.setSharerAddress("0xc0a10CF722b16D28aA963eD89f7DA915B63f4725", true);
}

setPredictionBonusSharePool()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });