// SPDX-License-Identifier: Apache-2.0

pragma solidity >=0.8.4 <0.9.0;
pragma abicoder v2;

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract DuelistKingFairDistributor is Ownable {
  // Total commited digest
  uint256 private totalCommitted;

  // Secret digests map
  mapping(uint256 => bytes32) private secretDigest;

  // Total revealed secret
  uint256 private totalRevealed;

  // Revealed secret values map
  mapping(uint256 => bytes32) private secretValues;

  // Oracle's address
  address private oracle;

  // Last reveal number
  uint64 private lastReveal;

  // Events
  event Committed(uint256 indexed index, bytes32 indexed digest);
  event Revealed(uint256 indexed index, uint192 indexed s, uint64 indexed t);

  // Only Duelist King Oracle allow to trigger smart contract
  modifier onlyOracle() {
    require(msg.sender == oracle, 'DuelistKingFairDistributor: Only allow to be called by oracle');
    _;
  }

  // Construct contract with oracle's address
  constructor(address oracleAddress) {
    oracle = oracleAddress;
  }

  // Deny to receive Ethereum
  receive() external payable {
    revert("DuelistKingFairDistributor: We won't receive ETH");
  }

  // Duelist King Oracle will commit H(S||t) to blockchain
  function commit(bytes32 digest) external onlyOracle returns (uint256) {
    uint256 index = totalCommitted;
    secretDigest[index] = digest;
    totalCommitted += 1;
    emit Committed(index, digest);
    return index;
  }

  // Duelist King Oracle will reveal S and t
  function reveal(bytes32 secret) external onlyOracle returns (uint256) {
    uint192 s;
    uint64 t;
    uint256 index = totalRevealed;
    // Decompose secret to its components
    assembly {
      s := and(t, 0xffffffffffffffff)
      t := shr(64, secret)
    }
    // We won't allow invalid timestamp
    require(t >= lastReveal, 'DuelistKingFairDistributor: Invalid time stamp');
    require(
      keccak256(abi.encodePacked(secret)) == secretDigest[index],
      "DuelistKingFairDistributor: Secret doesn't match digest"
    );
    secretValues[index] = secret;
    // Increase last reveal value
    lastReveal = t;
    totalRevealed += 1;
    emit Revealed(index, s, t);
    return index;
  }
}
