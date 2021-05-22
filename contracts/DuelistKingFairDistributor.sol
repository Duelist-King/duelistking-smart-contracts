// SPDX-License-Identifier: Apache-2.0

pragma solidity >=0.8.4 <0.9.0;
pragma abicoder v2;

import '@openzeppelin/contracts/access/Ownable.sol';
import './DuelistKingCard.sol';
import './DuelistKingRegistry.sol';
import './DuelistKingConst.sol';

contract DuelistKingFairDistributor is DuelistKingConst, Ownable {
  // Registry contract
  DuelistKingRegistry private registry;
  struct Campaign {
    // Total number of loot box
    uint64 totalSupply;
    // Remaining supply
    uint64 remainningSupply;
    // Number of card in each box
    uint64 totalCard;
    // Deadline
    uint64 deadline;
    // Card distribution
    uint256[] distribution;
  }

  mapping(uint256 => Campaign) private campaignStorage;

  uint256 totalCampaign = 0;

  modifier onlyRng() {
    // DuelistKingRng
    require(
      msg.sender == registry.getAddres(DuelistKingConst.Rng),
      'FairDistributor: Only allow calls from Duelist King RNG'
    );
    _;
  }

  constructor(address _registry) {
    registry = DuelistKingRegistry(_registry);
  }

  function newCampaign(Campaign calldata campaign) external onlyOwner returns (uint256) {
    totalCampaign += 1;
    campaignStorage[totalCampaign] = campaign;
    return totalCampaign;
  }

  function issueNewCard(bytes32 randomValue) external onlyRng returns (bool) {
    uint256 a = uint256(randomValue);
  }
}
