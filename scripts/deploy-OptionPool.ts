// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers} from 'hardhat'

const dcoinAddress = "0x079c29b4f37CEF7DDF6eC68A8BaC48A220eb72Bf";
const ethPull = "0x400FDC043Cf37988D7c100F8acdeCe3a46362d96";
import { BigNumber } from 'ethers'
async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  const OptionPool = await ethers.getContractFactory("OptionPool");
   let dfx = BigNumber.from("10000000000000000")
  const optionPool = await OptionPool.deploy(dcoinAddress, dfx, 0);
  await optionPool.deployed();
  await optionPool.addPool(100, ethPull, true, "ETHCall");
  console.log("Greeter deployed to:", optionPool.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
