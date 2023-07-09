import { ethers } from "hardhat";

async function main() {
  const PasskeySimpleAccount = await ethers.getContractFactory("secp256r1");
  // Deploy the contract
  const passkeySimpleAccount = await PasskeySimpleAccount.deploy();
  await passkeySimpleAccount.deployed();

  console.log("Secp256r1 contract deployed to : ", passkeySimpleAccount.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
