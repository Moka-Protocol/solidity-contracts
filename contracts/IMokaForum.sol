// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IMokaForum {
  function create(uint8 _amount, address _creator, string memory _title, string memory _desc, string memory _url, string[] memory _tags) external returns (bool);
  function upvote(uint8 _amount, address _voter, uint64 _postId) external returns (bool);
  function getPostCreator(uint64 _postId) external view returns(address);
}
