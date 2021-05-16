// SPDX-License-Identifier: Apache-2.0

pragma solidity >=0.8.4 <0.9.0;
pragma abicoder v2;

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import './DuelistKingCard.sol';

contract DuelistKingRegistry is Ownable {
  // Mapping bytes32 -> address
  mapping(bytes32 => address) private registered;

  // Mapping address -> bytes32
  mapping(address => bytes32) private reverted;

  // Event when new address registered
  event Registered(bytes32 indexed name, address indexed addr);

  // Set a record
  function set(bytes32 name, address addr) external onlyOwner returns (bool) {
    return _set(name, addr);
  }

  // Set many records at once
  function batchSet(bytes32[] calldata names, address[] calldata addrs) external onlyOwner returns (bool) {
    require(names.length == addrs.length, 'Registry: Number of records and addreses must be matched');
    for (uint256 i = 0; i < names.length; i += 1) {
      require(!_set(names[i], addrs[i]), 'Registry: Unable to set records');
    }
    return true;
  }

  // Get address by name
  function getAddress(bytes32 name) external view returns (address) {
    return registered[name];
  }

  // Get name by address
  function getName(address addr) external view returns (bytes32) {
    return reverted[addr];
  }

  // Set record internally
  function _set(bytes32 name, address addr) internal returns (bool) {
    registered[name] = addr;
    reverted[addr] = name;
    emit Registered(name, addr);
    return true;
  }
}
