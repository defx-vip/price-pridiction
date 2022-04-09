// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers} from 'hardhat'
const nftFactoryAddress = "0x429bd7860a45E928F9A52Cc32f891190b25c830d";
const defxAddress = "0x9E0F035628Ce4F5e02ddd14dEa2F7bd92B2A9152";
const bnbOracle = "0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526";
const adminAddress = "0x9e59Ba0D8a31094e714614Fd456e9a6ABa6925fA";
async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  const BNBLottery = await ethers.getContractFactory("BNBLottery");
  const bnbLottery = await BNBLottery.deploy();
  await bnbLottery.deployed();
  await bnbLottery.initialize(adminAddress, adminAddress, 28800, 20, 3, bnbOracle, nftFactoryAddress, defxAddress);
  //await bnbLottery.setPricePredictionReward("0x95Ea06a66032C09A1De25326d0eeB5DE4f1B0e8f");
  console.log("Greeter deployed to:", bnbLottery.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
