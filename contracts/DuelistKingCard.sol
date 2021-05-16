// SPDX-License-Identifier: Apache-2.0

pragma solidity >=0.8.4 <0.9.0;
pragma abicoder v2;

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import './DuelistKingRegistry.sol';

contract DuelistKingCard is ERC721('DKC', 'Duelist King Card'), Ownable {
  // Registry contract
  DuelistKingRegistry private registry;

  // Only distributor is allowed to mint() new card
  // In this case we use Duelist King Fair Distributor
  modifier onlyDistributor() {
    // DuelistKingFairDistributor
    require(
      msg.sender == registry.getAddress(0x4475656c6973744b696e67466169724469737472696275746f72000000000000),
      'Card: Only distributor able to trigger this method'
    );
    _;
  }

  constructor(address _registry) {
    registry = DuelistKingRegistry(_registry);
  }

  // Deny Ether
  receive() external payable {
    revert("Card: We won't receive ETH");
  }

  // Only owner able to mint new card
  // Duelist King Fair Distributor is owner of this contract
  function mint(address to, uint256 tokenId) external onlyDistributor returns (bool) {
    _mint(to, tokenId);
    return _exists(tokenId);
  }
}
