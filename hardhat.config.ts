import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "hardhat-erc1820";

const config: HardhatUserConfig = {
  networks: {
    hardhat: {},
    goeril: {
      url: "https://eth-goerli.alchemyapi.io/v2/FJeo2fsTSm9PoyhtB_5h0LLusAkm1YCW",
    },
  },
  solidity: {
    compilers: [
      {
        version: "0.8.17",
      },
      {
        version: "0.5.3",
      },
    ],
  },
};

export default config;
