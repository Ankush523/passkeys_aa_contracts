import { ethers } from "hardhat";

async function main() {
  const PasskeySimpleAccount = await ethers.getContractFactory("secp256r1");
  
  // Replace with the address of your desired entry point contract
  const entryPointAddress = "0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789";

  // Deploy the contract
  const passkeySimpleAccount = await PasskeySimpleAccount.deploy();
  await passkeySimpleAccount.deployed();

  console.log("secp deployed to:", passkeySimpleAccount.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
