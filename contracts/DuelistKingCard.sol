// SPDX-License-Identifier: Apache-2.0

pragma solidity >=0.8.4 <0.9.0;
pragma abicoder v2;

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';

contract DuelistKingCard is ERC721('DKD', 'Duelist King Card') {
  constructor() {}
}
