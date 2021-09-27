require("@nomiclabs/hardhat-waffle");

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  defaultNetwork: "bsc_test",
  networks: {
    hardhat: {
    },
    bsc_test: {
      url: "https://data-seed-prebsc-2-s1.binance.org:8545/",
      accounts: [],
      timeout: 60000
    },
    okex_test: {
      url: "https://exchaintestrpc.okex.org",
      accounts: []
    }
  },
  solidity: {
    version: "0.8.2",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  mocha: {
    timeout: 60000
  }
};
