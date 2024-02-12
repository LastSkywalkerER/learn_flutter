import {HardhatUserConfig} from "hardhat/config";
import "@nomicfoundation/hardhat-verify";
import "@nomicfoundation/hardhat-toolbox-viem";
import dotenv from 'dotenv'

dotenv.config()

const config: HardhatUserConfig = {
    solidity: {
        version: "0.8.20",
        settings: {
            optimizer: {
                enabled: true,
                runs: 100,
            },
            // viaIR: true,
        },
    },
    networks: {
        ["arbitrum-sepolia"]: {
            url: `https://arbitrum-sepolia.infura.io/v3/${process.env.INFURA}`,
            accounts: [process.env.PRIVATE_KEY || ""],
        },
    },
    etherscan: {
        apiKey: process.env.ETHERSCAN_KEY,
    },
    // gasReporter: {
    //     enabled: true,
    //     currency: "USD",
    //     coinmarketcap: process.env.COINMARKETCAP_API_KEY,
    // },
    sourcify: {
        // Disabled by default
        // Doesn't need an API key
        enabled: true
    }
};

export default config;
