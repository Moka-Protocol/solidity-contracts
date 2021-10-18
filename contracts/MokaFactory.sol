// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";

contract MokaFactory is Ownable {
  struct Forum {
    string uid;
    string name;
    address MokaForumAddr;
  }

  Forum[] public forums;

  function addForum(string memory _uid, string memory _name, address _mokaForumAddr) public onlyOwner {
    forums.push(Forum(_uid, _name, _mokaForumAddr));
  }

  function resetForum() public onlyOwner {
    delete forums;
  }

  function getForums() public view returns (Forum[] memory) {
    return forums;
  }
}