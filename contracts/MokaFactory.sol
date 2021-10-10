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

  function deleteForum(address _mokaForumAddr) public onlyOwner {
    for (uint i = 0; i < forums.length; i++) {
      if (forums[i].MokaForumAddr == _mokaForumAddr) {
        delete forums[i];
        break;
      }
    }
  }

  function getForums() public view returns (Forum[] memory) {
    return forums;
  }
}