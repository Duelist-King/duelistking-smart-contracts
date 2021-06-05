// SPDX-License-Identifier: Apache-2.0

pragma solidity >=0.8.4 <0.9.0;
pragma abicoder v2;

import 'dkdao/interfaces/IRNGConsumer.sol';
import 'dkdao/libraries/User.sol';
import './interfaces/ITheDivine.sol';
import './DuelistKingCard.sol';

/**
 * Card distributor
 * Name: Distributor
 * Domain: Duelist King
 */
contract DuelistKingFairDistributor is User, IRNGConsumer {
  // NFT by given domain
  using DuelistKingCard for uint256;

  // Card id of unique design
  uint256 private assignedCardId;

  // Private random
  uint256 private randomValue;

  // Campaign index
  uint256 campaignIndex;

  // The Divine
  ITheDivine private immutable theDivine;

  // Caompaign structure
  struct Campaign {
    // Total card
    uint128 totalCard;
    // Remaining card of current campaign
    uint128 remainingCard;
    // Deadline
    uint64 deadline;
    // Generation
    uint64 generation;
    // Start card Id
    uint64 start;
    // Number of rareness by distribution
    // 0-C,1-U,2-R,3-SR,4-SSR,5-L
    uint256[] rareness;
    // Card distribution
    uint256[] distribution;
    // Last deployed cards
    uint256[] deployed;
  }

  // Campaign storage
  mapping(uint256 => Campaign) private campaignStorage;

  // New campaign
  event NewCampaign(uint256 indexed campaginId, uint256 indexed generation, uint128 totalCard);
  // Found a card
  event NewCard(uint256 indexed campaginId, address indexed owner, uint256 indexed card);

  constructor(
    address _registry,
    bytes32 _domain,
    address divine
  ) {
    init(_registry, _domain);
    theDivine = ITheDivine(divine);
  }

  // Create new campaign
  function newCampaign(Campaign memory campaign) external onlyAllowSameDomain(bytes32('Oracle')) returns (uint256) {
    require(campaign.totalCard == campaign.remainingCard, 'FairDistributor: Total number and remaining must equal');
    require(
      campaign.rareness.length == campaign.distribution.length &&
        campaign.deployed.length == campaign.distribution.length,
      'FairDistributor: Number of item should be the same'
    );
    // Overwrite start with number of unique design
    // and then increase unique design to new card
    // To make sure card id won't be duplicated
    campaign.start = uint64(assignedCardId);
    assignedCardId += campaign.distribution.length;
    // Auto assign generation
    campaignIndex += 1;
    campaign.generation = uint64(campaignIndex / 25);
    campaignStorage[campaignIndex] = campaign;
    emit NewCampaign(campaignIndex, campaign.generation, campaign.totalCard);
    return campaignIndex;
  }

  // Compute random value from RNG
  function compute(bytes32 secret)
    external
    override
    onlyAllowCrossDomain(bytes32('DKDAO Infrasctructure'), bytes32('RNG'))
    returns (bool)
  {
    // We combine random value with the divine result to prevent manipulation
    // https://github.com/chiro-hiro/thedivine
    // Combine secret with with thedivine salt
    randomValue ^= uint256(secret) ^ theDivine.rand();
    return true;
  }

  // Calculate rareness
  function caculateRareness(
    Campaign memory currentCampaign,
    uint256 luckyNumber,
    uint256 currentSeek
  ) private pure returns (bool, uint256) {
    uint256 start;
    uint256 end;
    for (uint256 i = 0; i < currentSeek; i += 1) {
      start += currentCampaign.distribution[i];
    }
    end = start + currentCampaign.distribution[currentSeek];
    if (luckyNumber >= start && luckyNumber < end) {
      return (true, currentCampaign.rareness[currentSeek]);
    }
    // Otherwise return false
    return (false, 0);
  }

  // Calcualte card
  function caculateCard(Campaign memory currentCampaign, uint256 luckyNumber) private pure returns (uint256, uint256) {
    bool success;
    uint256 rareness;
    uint256 cardId;
    for (uint256 j = 0; j < currentCampaign.distribution.length; j += 1) {
      (success, rareness) = caculateRareness(currentCampaign, luckyNumber, j);
      if (success) {
        // Increase serial number by one
        cardId.setSerial(currentCampaign.deployed[j].getSerial() + 1);
        // Calculate card
        cardId.setId(currentCampaign.start + j);
        cardId.setRareness(rareness);
        cardId.setGeneration(currentCampaign.generation);
        return (j, cardId);
      }
    }
    return (0, 0);
  }

  // Open loot boxes
  function openBox(uint256 numberOfBoxes, address buyer)
    external
    onlyAllowSameDomain(bytes32('Oracle'))
    returns (bool)
  {
    // Make sure number of loot boxes won't be too munch
    require(
      numberOfBoxes == 1 || numberOfBoxes == 5 || numberOfBoxes == 10,
      'FairDistributor: Number of loot box must be 1/5/10'
    );

    Campaign memory currentCampaign = campaignStorage[campaignIndex];

    // Make sure card won't be sold after deadline
    if (currentCampaign.deadline > 0) {
      require(block.timestamp < currentCampaign.deadline, 'FairDistributor: The card sell was over');
    }
    if (
      currentCampaign.deadline == 0 &&
      currentCampaign.totalCard - currentCampaign.remainingCard >= (currentCampaign.totalCard / 4)
    ) {
      // If we reach soft cap we will close sell
      currentCampaign.deadline = uint64(block.timestamp + 3 days);
    }

    uint256 rand = randomValue;
    uint256 boughtCards = numberOfBoxes * 5;
    uint256 luckyNumber;
    uint256 card;
    uint256 cardIndex;
    for (uint256 i = 0; i < boughtCards; ) {
      // Repeat hash on its selft
      rand = uint256(keccak256(abi.encodePacked(rand)));
      luckyNumber = rand % currentCampaign.remainingCard;
      // Draw card by lucky number
      (cardIndex, card) = caculateCard(currentCampaign, luckyNumber);
      if (card > 0 && currentCampaign.distribution[cardIndex] > 0) {
        emit NewCard(campaignIndex, buyer, card);
        currentCampaign.remainingCard -= 1;
        currentCampaign.distribution[cardIndex] -= 1;
        i += 1;
      }
    }
    campaignStorage[campaignIndex] = currentCampaign;
    // Update the random value
    randomValue = rand;
    return true;
  }

  // Read campaign storage of given campaign index
  function getCampaign(uint256 index) external view returns (Campaign memory) {
    return campaignStorage[index];
  }
}
