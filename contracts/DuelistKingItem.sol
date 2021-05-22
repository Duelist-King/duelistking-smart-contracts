// SPDX-License-Identifier: Apache-2.0

pragma solidity >=0.8.4 <0.9.0;
pragma abicoder v2;

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import './DuelistKingRegistry.sol';
import './DuelistKingConst.sol';

contract DuelistKingItem is ERC721('DKI', 'Duelist King Item'), DuelistKingConst, Ownable {
  // Registry contract
  DuelistKingRegistry private registry;

  // Only distributor is allowed to mint() new Item
  // In this case we use Duelist King Fair Distributor
  modifier onlyDistributor() {
    require(
      msg.sender == registry.getAddress(DuelistKingConst.FairDistributor),
      'Item: Only distributor able to trigger this method'
    );
    _;
  }

  // Constructing with registry address
  constructor(address _registry) {
    registry = DuelistKingRegistry(_registry);
  }

  // Deny Ether
  receive() external payable {
    revert("Item: We won't receive ETH");
  }

  // Only distributor able to mint new Item
  function mint(address to, uint256 tokenId) external onlyDistributor returns (bool) {
    _mint(to, tokenId);
    return _exists(tokenId);
  }

  // We have 256 bits to store a Item id so we dicide to contain as much as posible data
  // Application      32  bits    0-Duelist King Card
  // Edition:         8   bits    For now, 0-Standard edition 0xff-Creator edition
  // Generation:      16  bits    Generation of item, now it's Gen 0
  // Rareness:        16  bits    0-C,1-U,2-R,3-SR,4-SSR,5-L
  // Type:            16  bits    0-Card, 1-Loot Box
  // Id:              32  bits    Increasement value that unique for each item
  // Serial:          32  bits    Increasement value that count the number of items
  // |type|edition|rareness|
  function itemId() {}
}
