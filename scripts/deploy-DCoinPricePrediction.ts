// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers} from 'hardhat'
const nftFactoryAddress = "0x8Fe97A7c1aDC4892df11c437f08eD29DC5ea4320";
const dcoinAddress = "0x079c29b4f37CEF7DDF6eC68A8BaC48A220eb72Bf";
const bnbOracle = "0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526";
const admin = "0x9e59Ba0D8a31094e714614Fd456e9a6ABa6925fA";
const userBonusAddress = "0x9E47914FbC820ca303F80D1c0834108c7F06daC6";
import { BigNumber } from 'ethers'
async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  const DCoinPricePrediction = await ethers.getContractFactory("DCoinPricePrediction");
  let dfx = BigNumber.from("10000000000000000")
  const dcoinPricePrediction = await DCoinPricePrediction.deploy();
  await dcoinPricePrediction.deployed();
  await dcoinPricePrediction.initialize(dcoinAddress, bnbOracle,admin, admin, 100 ,20, 10, 300, nftFactoryAddress, userBonusAddress);
  console.log("Greeter deployed to:", dcoinPricePrediction.address);
  let defxNFTFactory = await ethers.getContractAt( "DefxNFTFactory",nftFactoryAddress);
  await defxNFTFactory.setOperator(dcoinPricePrediction.address, true);
  let userBonus = await ethers.getContractAt( "UserBonus", userBonusAddress);
  await userBonus.setAllownUpdateBets(dcoinPricePrediction.address, true);
  console.info(dcoinPricePrediction.address)
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
