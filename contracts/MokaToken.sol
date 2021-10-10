// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./IMokaForum.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MokaToken is ERC20, Ownable {
  uint256 public constant _totalSupply = 3375775000;

  constructor() ERC20("Moka Token", "MOKA") {
    _mint(msg.sender, _totalSupply * uint256(10 ** 18));
  }

  function createPost(address _mokaForumAddr, uint8 _amount, string memory _title, string memory _desc, string memory _url, string[] memory _tags) public {
    transfer(_mokaForumAddr, _amount * uint256(10 ** 18));
    bool success = IMokaForum(_mokaForumAddr).create(_amount, msg.sender, _title, _desc, _url, _tags);
    require(success, "Post Failed");
  }

  function upvotePost(address _mokaForumAddr, uint8 _amount, uint64 _postId) public {
    address creator = IMokaForum(_mokaForumAddr).getPostCreator(_postId);
    transfer(creator, _amount * uint256(10 ** 18));
    bool success = IMokaForum(_mokaForumAddr).upvote(_amount, msg.sender, _postId);
    require(success, "Vote Failed");
  }
}