// SPDX-License-Identifier: Apache-2.0

pragma solidity >=0.8.4 <0.9.0;
pragma abicoder v2;

import '@openzeppelin/contracts/access/Ownable.sol';
import './DuelistKingCard.sol';
import './DuelistKingItem.sol';
import './DuelistKingRegistry.sol';
import './DuelistKingConst.sol';
import './interfaces/ITheDivine.sol';

contract DuelistKingFairDistributor is DuelistKingConst, Ownable {
  // Registry contract
  DuelistKingRegistry private immutable registry;

  // The Divine on Binance Smart Chain
  ITheDivine private immutable TheDivine = ITheDivine(0xF52a83a3B7d918B66BD9ae117519ddC436A82031);

  // Caompaign structure
  struct Campaign {
    // Remaining card
    uint18 totalCards;
    // Deadline
    uint18 deadline;
    // Card distribution
    uint256[] distribution;
  }

  // Buy order structure
  struct BuyOrder {
    uint256 campaign;
    uint128 quanity;
    uint128 memo;
    address beneficial;
  }

  mapping(uint256 => Campaign) private campaignStorage;

  mapping(uint256 => BuyOrder) private buyOrderStorage;

  uint256 campaignIndex = 0;

  uint256 buyOrderIndex = 0;

  event BuyLootBoxes(uint256 indexed campaign, uint256 indexed order, uint256 indexed memo);
  event OpenLootBoxes();

  modifier onlyRng() {
    // DuelistKingRng
    require(
      msg.sender == registry.getAddress(DuelistKingConst.Rng),
      'FairDistributor: Only allow calls from Duelist King RNG'
    );
    _;
  }

  modifier onlyValidOrder(BuyOrder memory newBuyOrder) {
    require(newBuyOrder.beneficial != address(0), 'FairDistributor: We do not accept zero address');
    require(newBuyOrder.campaign == campaignIndex, 'FairDistributor: Wrong campaign id');
    require(
      newBuyOrder.quanity == 1 || newBuyOrder.quanity == 5 || newBuyOrder.quanity == 10,
      'FairDistributor: Wrong quality of loot boxes'
    );
    _;
  }

  constructor(address _registry) {
    registry = DuelistKingRegistry(_registry);
  }

  function newCampaign(Campaign calldata campaign) external onlyOwner returns (uint256) {
    campaignIndex += 1;
    campaignStorage[campaignIndex] = campaign;
    return campaignIndex;
  }

  function buyLootBoxes(BuyOrder memory newBuyOrder) external onlyValidOrder(newBuyOrder) returns (uint256) {
    buyOrderIndex += 1;
    buyOrderStorage[buyOrderIndex] = newBuyOrder;
    // Emit loot box buy
    emit BuyLootBoxes(campaignIndex, buyOrderIndex, newBuyOrder.memo);
    return buyOrderIndex;
  }

  function openLootBox(bytes32 randomValue) external onlyRng returns (bool) {
    // We combine random value with the divine result to prevent manipulation
    // https://github.com/chiro-hiro/thedivine
    uint256 rnd = uint256(randomValue) ^ TheDivine.rand();
    Campaign memory currentCampaign = campaignStorage[campaignIndex];
    BuyOrder memory currentBuyOrder = buyOrderStorage[buyOrderIndex];
    uint256 boughtCards = currentBuyOrder.quanity * 5;
    uint256 luckyNumber = 0;
    for (uint256 i = 0; i < boughtCards; i += 1) {
      // Repeat on its selft
      rnd = uint256(keccak256(abi.encodePacked(rnd)));
      luckyNumber = rnd % currentCampaign.remainingCard;
      for (uint256 j = 0; j < currentCampaign.distribution.length; j += 1) {
        if(currentCampaign.distribution[j] )
      }
    }
  }
}
