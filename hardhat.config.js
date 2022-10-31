require("@nomicfoundation/hardhat-toolbox");
const fs = require('fs');

/** @type import('hardhat/config').HardhatUserConfig */

task("accounts", "Prints the list of accounts", async () => {
  const accounts = await ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  
  }
});

module.exports = {
  solidity: "0.8.9",
};
