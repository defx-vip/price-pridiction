// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers} from 'hardhat'
const userInfoAddress = "0xc7638674044228111A285C3A755262A57062Ce99";
const dcoinAddress = "0x079c29b4f37CEF7DDF6eC68A8BaC48A220eb72Bf";
async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  const UserBonus = await ethers.getContractFactory("UserBonus");
  const userBonus = await UserBonus.deploy(userInfoAddress, dcoinAddress);

  await userBonus.deployed();
  console.info(await userBonus.userInfo())
  console.log("Greeter deployed to:", userBonus.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
