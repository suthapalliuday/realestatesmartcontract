// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");
const fs = require('fs');



async function main() {

  const propertyToken = await hre.ethers.getContractFactory("PropertyTokenMinter");
  const ptoken = await propertyToken.deploy();

  const FractionalizeToken = await hre.ethers.getContractFactory("FractionalizeToken");
  const ftoken = await FractionalizeToken.deploy();

  const TradeSharesContract = await hre.ethers.getContractFactory("TradeShares");
  const tradeSharesContract = await TradeSharesContract.deploy();

  console.log("Address of depployed property token contract is :", ptoken.address);
  console.log("Address of deployed share token contract is : ",ftoken.address);
  console.log("Address of deployed trading share tokens contract is : ", tradeSharesContract.address);
  const ptokenData = {
    address: ptoken.address,
    abi: JSON.parse(ptoken.interface.format('json'))
  };
  const ftokenData = {
    address: ftoken.address,
    abi: JSON.parse(ftoken.interface.format('json'))
  };
  const tradeContractData = {
    address: tradeSharesContract.address,
    abi: JSON.parse(tradeSharesContract.interface.format('json'))
  };

  // const ftokenByteCode ={code: await hre.network.provider.send("eth_getCode", [ftoken.address])};
  
  fs.writeFileSync('../Realestate blockchain frontend/realestate/tokendata/pToken.json',JSON.stringify(ptokenData));
  fs.writeFileSync('../Realestate blockchain frontend/realestate/tokendata/fToken.json',JSON.stringify(ftokenData));
  fs.writeFileSync('../Realestate blockchain frontend/realestate/tokendata/tradeContractData.json',JSON.stringify(tradeContractData));
  
  // fs.writeFileSync('../Realestate blockchain frontend/realestate/tokendata/fTokenByteCode.json',JSON.stringify(ftokenByteCode))
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
