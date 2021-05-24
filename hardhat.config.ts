import { HardhatUserConfig } from 'hardhat/types';
import 'hardhat-typechain';
import '@nomiclabs/hardhat-ethers';

function contractName(name: string) {
  const buf = Buffer.alloc(32);
  buf.write(name);
  console.log(`bytes32 internal immutable ${name.replace('DuelistKing', '')} = 0x${buf.toString('hex')};`);
}

contractName('DuelistKingRegistry');
contractName('DuelistKingRng');
contractName('DuelistKingFairDistributor');
contractName('DuelistKingOracle');

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
        path: "m/44'/60'/0'/0",
      },
    },
  },
  solidity: {
    compilers,
  },
};

export default config;
