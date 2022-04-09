// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers} from 'hardhat'
const nftFactoryAddress = "0x429bd7860a45E928F9A52Cc32f891190b25c830d";
const defxAddress = "0x9E0F035628Ce4F5e02ddd14dEa2F7bd92B2A9152";
const admin ="0x9e59Ba0D8a31094e714614Fd456e9a6ABa6925fA";
import { BigNumber } from 'ethers'
async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  const MysteryBox = await ethers.getContractFactory("MysteryBox");
   let dfx = BigNumber.from("10000000000000000000")
  const mysteryBox = await MysteryBox.deploy();
  await mysteryBox.deployed();
  await mysteryBox.addBoxFactory("Test1", nftFactoryAddress, 1000, admin, defxAddress, dfx);
  console.log("MysteryBox deployed to:", mysteryBox.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
