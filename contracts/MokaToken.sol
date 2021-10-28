// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./DateTimeLibrary.sol";
import "./IMokaPosts.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MokaToken is ERC20, Ownable {
  uint8 public POST_PRICE = 6;
  uint8 public VOTE_PRICE = 1;
  uint256 public constant _totalSupply = 3400000000;
  address public mokaPostsContract;

  struct SettledPrizePost {
    bytes32 dateId;
    uint8 rank;
    uint256 prize;
    uint256 postId;
    address user;
    address postsContract;
  }

  mapping(bytes32 => uint32) public dailyPrizeRewards;
  mapping(bytes32 => uint32) public weeklyPrizeRewards;
  mapping(bytes32 => uint32) public monthlyPrizeRewards;

  mapping(bytes32 => SettledPrizePost[]) public dailyPrizeOutcome;
  mapping(bytes32 => SettledPrizePost[]) public weeklyPrizeOutcome;
  mapping(bytes32 => SettledPrizePost[]) public monthlyPrizeOutcome;

  event SettledDailyPrize(bytes32 dailyId, SettledPrizePost[]);
  event SettledWeeklyPrize(bytes32 weeklyId, SettledPrizePost[]);
  event SettledMonthlyPrize(bytes32 monthlyId, SettledPrizePost[]);

  event PrizePoolIncreased(bytes32 dailyId, bytes32 weeklyId, bytes32 monthlyId, uint256 uid);
  event UserUpvote(address voterAddr, address creatorAddr);

  constructor() ERC20("Moka Token", "MOKA") {
    _mint(msg.sender, _totalSupply * uint256(10 ** 18));
  }

  function createPost(string memory _post, string[] memory _tags) public {
    transfer(owner(), POST_PRICE * uint256(10 ** 18));
    (bytes32 monthId, bytes32 weekId, bytes32 dayId) = DateTimeLibrary.timestampToTimeBlocks(block.timestamp);
    monthlyPrizeRewards[monthId] += (POST_PRICE / 3);
    weeklyPrizeRewards[weekId] += (POST_PRICE / 3);
    dailyPrizeRewards[dayId] += (POST_PRICE / 3);
    (bool success, uint256 uid) = IMokaPosts(mokaPostsContract).createPost(msg.sender, monthId, weekId, dayId, _post, _tags);
    require(success, "Post Failed");
    emit PrizePoolIncreased(dayId, weekId, monthId, uid);
  }

  function upvotePost(address _creator, uint256 _uid) public {
    transfer(_creator, VOTE_PRICE * uint256(10 ** 18));
    bool success = IMokaPosts(mokaPostsContract).upvotePost(msg.sender, _creator, _uid);
    require(success, "Vote Failed");
    emit UserUpvote(msg.sender, _creator);
  }

  function setPostsContract(address _mokaPostsContract) public onlyOwner {
    mokaPostsContract = _mokaPostsContract;
  }

  function settleDailyPrize(bytes32 _dailyId, SettledPrizePost[] memory settledPosts) public onlyOwner {
    require(dailyPrizeOutcome[_dailyId].length == 0, "Pool Already Settled");

    for (uint8 i = 0; i < settledPosts.length; i++) {
      transfer(settledPosts[i].user, settledPosts[i].prize);
      dailyPrizeOutcome[_dailyId].push(settledPosts[i]);
    }

    emit SettledDailyPrize(_dailyId, settledPosts);
  }

  function settleWeeklyPrize(bytes32 _weeklyId, SettledPrizePost[] memory settledPosts) public onlyOwner {
    require(weeklyPrizeOutcome[_weeklyId].length == 0, "Pool Already Settled");

    for (uint8 i = 0; i < settledPosts.length; i++) {
      transfer(settledPosts[i].user, settledPosts[i].prize);
      weeklyPrizeOutcome[_weeklyId].push(settledPosts[i]);
    }

    emit SettledWeeklyPrize(_weeklyId, settledPosts);
  }

  function settleMonthlyPrize(bytes32 _monthlyId, SettledPrizePost[] memory settledPosts) public onlyOwner {
    require(monthlyPrizeOutcome[_monthlyId].length == 0, "Pool Already Settled");

    for (uint8 i = 0; i < settledPosts.length; i++) {
      transfer(settledPosts[i].user, settledPosts[i].prize);
      monthlyPrizeOutcome[_monthlyId].push(settledPosts[i]);
    }

    emit SettledMonthlyPrize(_monthlyId, settledPosts);
  }
}