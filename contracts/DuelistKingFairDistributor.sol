// SPDX-License-Identifier: Apache-2.0

pragma solidity >=0.8.4 <0.9.0;
pragma abicoder v2;

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import './DuelistKingCard.sol';

contract DuelistKingFairDistributor is Ownable {

  struct Campaign{
    // Total number of loot box
    uint256 totalSupply;
    // Card distribution
    uint256[] distribution;
  }

  mapping (uint256=>Campaign) private campaignStorage;

  uint256 totalCampaign = 0;

  function newCampaign(Campaign calldata newCampaign) external onlyOwner returns(uint256) {

  }

}
