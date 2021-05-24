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

  // Only distributor able to mint new Item
  function mint(address to, uint256 tokenId) external onlyDistributor returns (bool) {
    _mint(to, tokenId);
    return _exists(tokenId);
  }

}
