// SPDX-License-Identifier: Apache-2.0

pragma solidity >=0.8.4 <0.9.0;
pragma abicoder v2;

/**
 * Card of Duelist King
 * Name: Card
 * Domain: Duelist King
 */
library DuelistKingCard {
  // We have 256 bits to store an item's id so we dicide to contain as much as posible data
  // Application      64  bits    We can't control this, it will be assigned by DKDAO

  // Edition:         16  bits    For now, 0-Standard edition 0xff-Creator edition
  // Generation:      16  bits    Generation of item, now it's Gen 0
  // Rareness:        16  bits    0-C, 1-U, 2-R, 3-SR, 4-SSR, 5-L
  // Type:            16  bits    0-Card, 1-Loot Box
  // Id:              64  bits    Increasement value that unique for each item
  // Serial:          64  bits    Increasement value that count the number of items
  // 256         192         176             160            144         128       64            0 
  //  |application|  edition  |  generation   |   rareness   |   type    |   id    |   seiral   |
  function set(
    uint256 value,
    uint256 shift,
    uint256 mask,
    uint256 newValue
  ) internal pure returns (uint256 result) {
    require((mask | newValue) ^ mask == 0, 'Card: New value is out range');
    assembly {
      result := and(value, not(shl(shift, mask)))
      result := or(shl(shift, newValue), result)
    }
  }

  function get(
    uint256 value,
    uint256 shift,
    uint256 mask
  ) internal pure returns (uint256 result) {
    assembly {
      result := shr(shift, and(value, shl(shift, mask)))
    }
  }

  function setSerial(uint256 a, uint256 b) internal pure returns (uint256 c) {
    return set(a, 0, 0xffffffffffffffff, b);
  }

  function getSerial(uint256 a) internal pure returns (uint256 c) {
    return get(a, 0, 0xffffffffffffffff);
  }

  function setId(uint256 a, uint256 b) internal pure returns (uint256 c) {
    return set(a, 64, 0xffffffffffffffff, b);
  }

  function getId(uint256 a) internal pure returns (uint256 c) {
    return get(a, 64, 0xffffffffffffffff);
  }

  function setType(uint256 a, uint256 b) internal pure returns (uint256 c) {
    return set(a, 128, 0xffff, b);
  }

  function getType(uint256 a) internal pure returns (uint256 c) {
    return get(a, 128, 0xffff);
  }

  function setRareness(uint256 a, uint256 b) internal pure returns (uint256 c) {
    return set(a, 144, 0xffff, b);
  }

  function getRareness(uint256 a) internal pure returns (uint256 c) {
    return get(a, 144, 0xffff);
  }

  function setGeneration(uint256 a, uint256 b) internal pure returns (uint256 c) {
    return set(a, 160, 0xffff, b);
  }

  function getGeneration(uint256 a) internal pure returns (uint256 c) {
    return get(a, 160, 0xffff);
  }

  function setEdition(uint256 a, uint256 b) internal pure returns (uint256 c) {
    return set(a, 176, 0xffff, b);
  }

  function getEdition(uint256 a) internal pure returns (uint256 c) {
    return get(a, 176, 0xffff);
  }
}
