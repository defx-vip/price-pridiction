// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers} from 'hardhat'
const nftAddress = "0xDF166dfB9c37EaD80A0C3FC48ee78e199E70AF8F";

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  const DefxNFT = await ethers.getContractFactory("DefxNFT");
  const defxNFT = await DefxNFT.deploy();
  await defxNFT.deployed();

  const DefxNFTFactory = await ethers.getContractFactory("DefxNFTFactory");
  const defxNFTFactory = await DefxNFTFactory.deploy();
  await defxNFTFactory.deployed();
  await defxNFTFactory.initialize(defxNFT.address, 20);
  let MINT_ROLE = await defxNFT.MINT_ROLE();
  await defxNFT.grantRole( MINT_ROLE, defxNFTFactory.address);
  console.log("DefxNFTFactory deployed to:", defxNFTFactory.address);
  console.log("DefxNFT deployed to:", defxNFT.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
