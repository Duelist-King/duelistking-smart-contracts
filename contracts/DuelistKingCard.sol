// SPDX-License-Identifier: Apache-2.0

pragma solidity >=0.8.4 <0.9.0;
pragma abicoder v2;

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract DuelistKingCard is ERC721('DKC', 'Duelist King Card'), Ownable {
  // Distributor address
  address private distributor;

  // Transfer Distribute Right to another address
  event TransferDistributeRight(address indexed oldDistributor, address indexed newDistributor);

  // Only distributor is allowed to mint() new card
  // In this case we use Duelist King Fair Distributor
  modifier onlyDistributor() {
    require(msg.sender == distributor, 'Card: Only distributor able to trigger this method');
    _;
  }

  constructor(address distributorAddr) {
    _changeDistributor(distributorAddr);
  }

  // Deny Ether
  receive() external payable {
    revert("Card: We won't receive ETH");
  }

  // Change distributor, ony owner able to do
  function changeDistributor(address newDistributor) external onlyOwner returns (bool) {
    return _changeDistributor(newDistributor);
  }

  // Only owner able to mint new card
  // Duelist King Fair Distributor is owner of this contract
  function mint(address to, uint256 tokenId) external onlyDistributor returns (bool) {
    _mint(to, tokenId);
    return _exists(tokenId);
  }

  function _changeDistributor(address newDistributor) internal returns (bool) {
    emit TransferDistributeRight(distributor, newDistributor);
    distributor = newDistributor;
    return true;
  }
}
