import { ethers} from 'hardhat'
import { BigNumber } from 'ethers'
const nftFactoryAddress = "0x4566Cf31B204985259aDb368337D9C8d1ec92E96";
const erc20 = "0x9E0F035628Ce4F5e02ddd14dEa2F7bd92B2A9152";
const add = "0x4C86978D848925a88a61ef1b7dA61574D531C1ea";
const nftAddress = "0xEe4A39bf41355c2F1546d4a4FFCa0C808dF32095";
async function nftFactorySetOperator() {
    let nftFactory = await ethers.getContractAt( "DefxNFTFactory", nftFactoryAddress);
    await nftFactory.setOperator(add, true);
    console.info(`nftFactorySetOperator: ${add} 授权成功`);
}

async function erc20Approve() {
    let defx = await ethers.getContractAt( "ERC20", erc20);
    let num = BigNumber.from("100000000000000000000")
    await defx.approve(add, num) ;
  
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

saleNFT()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });