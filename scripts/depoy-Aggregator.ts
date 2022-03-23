import { ethers} from 'hardhat'
import { BigNumber } from 'ethers'
const dcoinPredictionAdd = "0x1346caE4284d7E6BBBF0BFb3B26a20530C9dF4D3";
async function main() {
    // Hardhat always runs the compile task when running scripts with its command
    // line interface.
    //
    // If this script is run directly using `node` you may want to call compile
    // manually to make sure everything is compiled
    // await hre.run('compile');
  
    // We get the contract to deploy
    const AggregatorV3InterfaceImpl = await ethers.getContractFactory("AggregatorV3InterfaceImpl");
    let price = BigNumber.from("400000000")
    const aggregatorV3InterfaceImpl = await AggregatorV3InterfaceImpl.deploy();
    await aggregatorV3InterfaceImpl.deployed();
    await aggregatorV3InterfaceImpl.setLastPrice(price);
    // console.log("Greeter deployed to:", dcoinPricePrediction.address);
    //let defxNFTFactory = await ethers.getContractAt( "DefxNFTFactory",nftFactoryAddress);
    //await defxNFTFactory.setOperator(dcoinPricePrediction.address, true);
    let dcoinPrediction = await ethers.getContractAt( "DCoinPricePrediction", dcoinPredictionAdd);
    await  dcoinPrediction.setOracle(aggregatorV3InterfaceImpl.address);
    console.info(aggregatorV3InterfaceImpl.address)
  }
  
  // We recommend this pattern to be able to use async/await everywhere
  // and properly handle errors.
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });
  