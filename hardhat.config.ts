import { HardhatUserConfig } from 'hardhat/types';
import 'hardhat-typechain';
import dotenv from 'dotenv';

dotenv.config();

let { DUELIST_KING_MNEMONIC, DUELIST_KING_RPC_URL } = process.env;
DUELIST_KING_MNEMONIC = (DUELIST_KING_MNEMONIC || '').trim();
DUELIST_KING_RPC_URL = (DUELIST_KING_RPC_URL || '').trim();

const compilers = ['0.8.4'].map((item: string) => ({
  version: item,
  settings: {
    optimizer: {
      enabled: true,
      runs: 200,
    },
  },
}));

const config: HardhatUserConfig = {
  defaultNetwork: 'hardhat',
  networks: {
    // Do forking mainnet to test
    hardhat: {
      blockGasLimit: 12500000,
      gas: 6500000,
      gasPrice: 2000000000,
      hardfork: 'berlin',
      accounts: {
        mnemonic: DUELIST_KING_MNEMONIC,
        path: "m/44'/60'/0'/0",
      },
      forking: {
        url: DUELIST_KING_RPC_URL,
        enabled: true,
      },
    },
  },
  solidity: {
    compilers,
  },
};

export default config;
