import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "hh-acc-abs-toolkit"

const config: HardhatUserConfig = {
  solidity: "0.8.18",
  networks: {
    localhost: {
      url: "http://localhost:8545",
      blockGasLimit: 60000000
    }
  }
};

export default config;
