// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers} from 'hardhat'
const nftFactoryAddress = "0x4566Cf31B204985259aDb368337D9C8d1ec92E96";
const userInfoAddress = "0xcB4Bc901073bae6E4ef172Aca135B393dbd9Bf7E";
const dcoinAddress = "0x079c29b4f37CEF7DDF6eC68A8BaC48A220eb72Bf";
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
  console.log("DefxNFT deployed to:", defxNFT.address);
  console.log("DefxNFTFactory deployed to:", defxNFT.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });