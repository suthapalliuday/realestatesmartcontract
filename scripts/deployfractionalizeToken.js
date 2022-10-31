const hre = require("hardhat");
const fs = require('fs');


export async function main(tokenId) {
    
    const FractionalizeToken = await hre.ethers.getContractFactory("FractionalizeToken");
    const ftoken = await FractionalizeToken.deploy();

    console.log("Address of deployed share token contract is : ",ftoken.address);

    const ftokenData = {
        address: ptoken.address,
        abi: JSON.parse(ptoken.interface.format('json'))
    };

    fs.writeFileSync(`../Realestate blockchain frontend/realestate/tokendata/fToken${tokenId}.json`,JSON.stringify(ftokenData));


}


//  main().catch((error) => {
//     console.error(error);
//     process.exitCode = 1;
//   });