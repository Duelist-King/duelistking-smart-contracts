import hre from 'hardhat';
import { expect } from 'chai';
import { Signer } from 'ethers';

async function contractDeploy(actor: Signer, contractName: string, ...params: any[]) {
  const instanceFactory = await hre.ethers.getContractFactory(contractName);
  const instance = await instanceFactory.connect(actor).deploy(...params);
  return instance;
}

describe('a', () => {
  it('b', async () => {});
});
