// SPDX-License-Identifier: Apache-2.0

pragma solidity >=0.8.4 <0.9.0;
pragma abicoder v2;

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract DuelistKingCard is ERC721('DKD', 'Duelist King Card'), Ownable {
  receive() external payable {
    revert("DuelistKingCard: We won't receive ETH");
  }

  // Only owner able to mint new card
  // Duelist King Fair Distributor is owner of this contract
  function mint(address to, uint256 tokenId) external onlyOwner {
    _mint(to, tokenId);
  }
}
