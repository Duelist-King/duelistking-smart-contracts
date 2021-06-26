// SPDX-License-Identifier: Apache-2.0

pragma solidity >=0.8.4 <0.9.0;
pragma abicoder v2;

import 'dkdao/interfaces/IRNGConsumer.sol';
import 'dkdao/libraries/User.sol';
import 'dkdao/libraries/Bytes.sol';
import 'dkdao/interfaces/ITheDivine.sol';
import 'dkdao/interfaces/INFT.sol';
import 'dkdao/interfaces/IPress.sol';

/**
 * Card distributor
 * Name: Distributor
 * Domain: Duelist King
 */
contract DuelistKingDistributor is User, IRNGConsumer {
  // Using Bytes for bytes
  using Bytes for bytes;

  // Number of seiral
  uint256 private serial;

  // Campaign index
  uint256 campaignIndex;

  // The Divine
  ITheDivine private immutable theDivine;

  // Card index
  uint256 cardIndex;

  // Card storage
  mapping(uint256 => address) cardStorage;

  // Entropy data
  uint256 private entropy;

  // Campaign structure
  struct Campaign {
    // Total number of issued card
    uint64 opened;
    // Soft cap of card distribution
    uint64 softCap;
    // Deadline of timestamp
    uint64 deadline;
    // Generation
    uint64 generation;
    // Start card Id
    uint64 start;
    // Start end card Id
    uint64 end;
    // Unique design
    uint64 designs;
    // Card distribution
    uint256[] distribution;
  }

  // Campaign storage
  mapping(uint256 => Campaign) private campaignStorage;

  // New campaign
  event NewCampaign(uint256 indexed campaginId, uint256 indexed generation, uint64 indexed designs);

  // New card
  event NewCard(uint256 indexed cardIndex, address indexed cardAddress, string indexed cardName);

  constructor(
    address _registry,
    bytes32 _domain,
    address divine
  ) {
    _init(_registry, _domain);
    theDivine = ITheDivine(divine);
  }

  // Create new campaign
  function newCampaign(Campaign memory campaign) external onlyAllowSameDomain('Oracle') returns (uint256) {
    require(
      (campaign.end - campaign.start) == campaign.designs,
      'Distributor: Number of deisgns and number of issued NFTs must be the same'
    );
    // Overwrite start with number of unique design
    // and then increase unique design to new card
    // To make sure card id won't be duplicated
    // Auto assign generation
    campaignIndex += 1;
    campaign.generation = uint64(campaignIndex / 25);
    campaignStorage[campaignIndex] = campaign;
    emit NewCampaign(campaignIndex, campaign.generation, campaign.designs);
    return campaignIndex;
  }

  // Compute random value from RNG
  function compute(bytes memory data)
    external
    override
    onlyAllowCrossDomain('DKDAO Infrastructure', 'RNG')
    returns (bool)
  {
    require(data.length == 32, 'Distributor: Data must be 32 in length');
    // We combine random value with The Divine's result to prevent manipulation
    // https://github.com/chiro-hiro/thedivine
    entropy ^= uint256(data.readUint256(0)) ^ theDivine.rand();
    return true;
  }

  // Calcualte card
  function caculateCard(Campaign memory currentCampaign, uint256 luckyNumber) private pure returns (uint256) {
    for (uint256 i = 0; i < currentCampaign.distribution.length; i += 1) {
      uint256 t = currentCampaign.distribution[i];
      uint256 mask = t & 0xffffffffffffffff;
      uint256 difficulty = (t >> 64) & 0xffffffffffffffff;
      uint256 factor = (t >> 128) & 0xffffffffffffffff;
      uint256 start = (t >> 192) & 0xffffffffffffffff;
      if ((luckyNumber & mask) < difficulty) {
        // Return card Id
        return currentCampaign.start + start + (luckyNumber % factor);
      }
    }
    return 0;
  }

  // Open loot boxes
  function openBox(
    uint256 campaignId,
    address buyer,
    uint256 numberOfBoxes
  ) external onlyAllowSameDomain('Oracle') returns (bool) {
    require(
      numberOfBoxes == 1 || numberOfBoxes == 5 || numberOfBoxes == 10,
      'Distributor: Invalid number of loot boxes'
    );
    require(campaignId > 0 && campaignId <= campaignIndex, 'Distributor: Invalid campaign Id');
    Campaign memory currentCampaign = campaignStorage[campaignId];
    currentCampaign.opened += uint64(numberOfBoxes);
    // Set deadline if softcap is reached
    if (currentCampaign.deadline > 0) {
      require(block.timestamp > currentCampaign.deadline, 'Distributor: Card sale is over');
    }
    if (currentCampaign.deadline == 0 && currentCampaign.opened > currentCampaign.softCap) {
      currentCampaign.deadline = uint64(block.timestamp + 3 days);
    }
    uint256 rand = entropy;
    uint256 boughtCards = numberOfBoxes * 5;
    uint256 luckyNumber;
    uint256 card;
    uint256 cardSerial = serial;
    for (uint256 i = 0; i < boughtCards; ) {
      // Repeat hash on its selft
      rand = uint256(keccak256(abi.encodePacked(rand)));
      for (uint256 j = 0; j < 256 && i < boughtCards; j += 32) {
        luckyNumber = (rand >> j) & 0xffffffff;
        // Draw card by lucky number
        card = caculateCard(currentCampaign, luckyNumber);
        if (card > 0) {
          cardSerial += 1;
          INFT(cardStorage[card]).mint(buyer, cardSerial);
          i += 1;
        }
      }
    }
    serial = cardSerial;
    campaignStorage[campaignId] = currentCampaign;
    // Update old random with new one
    entropy = rand;
    return true;
  }

  // Open loot boxes
  function issueCard(string calldata name, string calldata symbol)
    external
    onlyAllowSameDomain('Oracle')
    returns (bool)
  {
    cardIndex += 1;
    address addrNFT = IPress(registry.getAddress('DKDAO Infrastructure', 'Press')).newNFT(domain, name, symbol);
    cardStorage[cardIndex] = addrNFT;
    emit NewCard(cardIndex, addrNFT, name);
    return true;
  }

  // Read campaign storage of a given campaign index
  function getCampaignIndex() external view returns (uint256) {
    return campaignIndex;
  }

  // Read campaign storage of a given campaign index
  function getCampaign(uint256 index) external view returns (Campaign memory) {
    return campaignStorage[index];
  }

  // Get card index
  function getCardIndex() external view returns (uint256) {
    return cardIndex;
  }

  // Read card storage of a given card index
  function getCard(uint256 index) external view returns (address) {
    return cardStorage[index];
  }
}
