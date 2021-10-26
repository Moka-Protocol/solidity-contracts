// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IMokaPosts {
  function createPost(address _creator, bytes32 _monthId, bytes32 _weekId, bytes32 _dayId, string memory _post, string[] memory _tags) external returns (bool, uint256);
  function upvotePost(address _voter, address _creator, uint256 _uid) external returns (bool);
}
