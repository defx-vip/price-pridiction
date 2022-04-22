// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers} from 'hardhat'
const nftFactoryAddress = "0x8Fe97A7c1aDC4892df11c437f08eD29DC5ea4320";
const dcoinAddress = "0x079c29b4f37CEF7DDF6eC68A8BaC48A220eb72Bf";
const defxAddress = "0x9E0F035628Ce4F5e02ddd14dEa2F7bd92B2A9152";
import { BigNumber } from 'ethers'
async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  const DefxNFTPool = await ethers.getContractFactory("DefxNFTPool");
   let dfx = BigNumber.from("10000000000000000")
  const defxNFTPool = await DefxNFTPool.deploy(0, dfx, dfx, defxAddress, dcoinAddress, nftFactoryAddress);
  await defxNFTPool.deployed();
  let nftFactory = await ethers.getContractAt( "DefxNFTFactory", nftFactoryAddress);
  await nftFactory.setOperator(defxNFTPool.address, true);
  console.log("Greeter deployed to:", defxNFTPool.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
