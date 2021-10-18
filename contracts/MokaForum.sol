// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./MokaForumPosts.sol";
import "./DateTimeLibrary.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MokaForum is Ownable {
  uint8 public POST_PRICE;
  uint8 public VOTE_PRICE;
  string public uid;
  string public name;
  address public mokaERC20Contract;
  MokaForumPosts public postsContract;

  struct SettledPrizePost {
    string dateId;
    uint8 rank;
    uint256 prize;
    uint64 postId;
    address user;
  }

  mapping(string => uint32) public dailyPrizePool;
  mapping(string => uint32) public weeklyPrizePool;
  mapping(string => uint32) public monthlyPrizePool;
  mapping(address => uint32) public votesBy;
  mapping(address => uint32) public votesFor;

  mapping(string => SettledPrizePost[]) public settledDailyPrizePool;
  mapping(string => SettledPrizePost[]) public settledWeeklyPrizePool;
  mapping(string => SettledPrizePost[]) public settledMonthlyPrizePool;

  event PrizePoolIncreased(string dailyId, string weeklyId, string monthlyId, uint8 amount);
  event UserUpvotePost(address voterAddr, address postAddr, uint8 amount);
  event SettledDailyPrize(string dailyId, SettledPrizePost[]);
  event SettledWeeklyPrize(string weeklyId, SettledPrizePost[]);
  event SettledMonthlyPrize(string monthlyId, SettledPrizePost[]);

  constructor(uint8 _postPrice, uint8 _votePrice, string memory _uid, string memory _name, address _mokaERC20Contract) {
    POST_PRICE = _postPrice;
    VOTE_PRICE = _votePrice;
    uid = _uid;
    name = _name;
    mokaERC20Contract = _mokaERC20Contract;
    postsContract = new MokaForumPosts(address(this), _uid);
  }

  function create(uint8 _amount, address _creator, string memory _title, string memory _desc, string memory _url, string[] memory _tags) public returns (bool) {
    require(msg.sender == mokaERC20Contract, "ERC20 Contract Only");
    require(_amount == POST_PRICE, "Post Price Incorrect");
    (string memory monthBlock, string memory weekBlock, string memory dayBlock) = DateTimeLibrary.timestampToTimeBlocks(block.timestamp);
    bool addSuccess = postsContract.createPost(monthBlock, weekBlock, dayBlock, _creator, _title, _desc, _url, _tags);
    require(addSuccess, "Add Post Fail");
    monthlyPrizePool[monthBlock] += (_amount / 3);
    weeklyPrizePool[weekBlock] += (_amount / 3);
    dailyPrizePool[dayBlock] += (_amount / 3);
    emit PrizePoolIncreased(dayBlock, weekBlock, monthBlock, (_amount / 3));
    return true;
  }
  
  function upvote(uint8 _amount, address _voter, uint64 _postId) public returns (bool) {
    require(msg.sender == mokaERC20Contract, "ERC20 Contract Only");
    require(_amount == VOTE_PRICE, "Vote Price Incorrect");
    (bool voteSuccess, address creator) = postsContract.upvotePost(_postId, _voter);
    require(voteSuccess, "Vote Post Fail");
    votesBy[_voter] += _amount;
    votesFor[creator] += _amount;
    emit UserUpvotePost(_voter, creator, _amount);
    return true;
  }

  function getPostCreator(uint64 _postId) public view returns(address) {
    return postsContract.getPostCreator(_postId);
  }

  function settleDailyPrize(string memory _dailyId, SettledPrizePost[] memory settledPosts) public onlyOwner {
    require(settledDailyPrizePool[_dailyId].length == 0, "Pool Already Settled");

    for (uint8 i = 0; i < settledPosts.length; i++) {
      bool success = IERC20(mokaERC20Contract).transfer(settledPosts[i].user, settledPosts[i].prize);
      require(success, "Payment Failed");
      settledDailyPrizePool[_dailyId].push(settledPosts[i]);
    }

    emit SettledDailyPrize(_dailyId, settledPosts);
  }

  function settleWeeklyPrize(string memory _weeklyId, SettledPrizePost[] memory settledPosts) public onlyOwner {
    require(settledWeeklyPrizePool[_weeklyId].length == 0, "Pool Already Settled");

    for (uint8 i = 0; i < settledPosts.length; i++) {
      bool success = IERC20(mokaERC20Contract).transfer(settledPosts[i].user, settledPosts[i].prize);
      require(success, "Payment Failed");
      settledWeeklyPrizePool[_weeklyId].push(settledPosts[i]);
    }

    emit SettledWeeklyPrize(_weeklyId, settledPosts);
  }

  function settleMonthlyPrize(string memory _monthlyId, SettledPrizePost[] memory settledPosts) public onlyOwner {
    require(settledMonthlyPrizePool[_monthlyId].length == 0, "Pool Already Settled");

    for (uint8 i = 0; i < settledPosts.length; i++) {
      bool success = IERC20(mokaERC20Contract).transfer(settledPosts[i].user, settledPosts[i].prize);
      require(success, "Payment Failed");
      settledMonthlyPrizePool[_monthlyId].push(settledPosts[i]);
    }

    emit SettledMonthlyPrize(_monthlyId, settledPosts);
  }
}