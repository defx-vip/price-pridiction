// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers} from 'hardhat'
const nftFactoryAddress = "0x8Fe97A7c1aDC4892df11c437f08eD29DC5ea4320";

const USDTAddress = "0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684";
const bnbOracle = "0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526";
const admin = "0x5f9808b04Af758cDaa1C44430503fCEC61E91E02";
import { BigNumber } from 'ethers'
async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  const BnbPriceUSDTPrediction = await ethers.getContractFactory("BnbPriceUSDTPrediction");
  const dcoinPricePrediction = await BnbPriceUSDTPrediction.deploy();
  await dcoinPricePrediction.deployed();
  await dcoinPricePrediction.initialize(USDTAddress, bnbOracle,admin, admin, 100 ,20, 10, 100, 80, 20, 300, nftFactoryAddress);
  console.log("Greeter deployed to:", dcoinPricePrediction.address);
  let defxNFTFactory = await ethers.getContractAt( "DefxNFTFactory", nftFactoryAddress);
  await defxNFTFactory.setOperator(dcoinPricePrediction.address, true);
  
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
