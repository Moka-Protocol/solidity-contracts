// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MokaTokenSale is Ownable {
  using SafeMath for uint256;

  IERC20 mokaTokenContract;
  uint256 public userCount;
  string[] public acceptedStablecoins;
  mapping(address => uint256) public addressUserMapping;
  mapping(string => address) public stablecoinContracts;
  mapping(string => uint8) public stablecoinDecimals;

  /* Price Bands For User Sign Up */
  struct PriceBand {
    uint32 userCount;
    uint16 mokaToken;
    uint8 price;
  }

  PriceBand[8] public tokenDistribution;

  event userJoined(uint256 userNumber, address userAddress);

  constructor(address tokenAddr) {
    userCount = 0;
    mokaTokenContract = IERC20(tokenAddr);

    tokenDistribution[0] = PriceBand(0, 1000, 5);
    tokenDistribution[1] = PriceBand(101, 750, 5);
    tokenDistribution[2] = PriceBand(1001, 500, 10);
    tokenDistribution[3] = PriceBand(10001, 250, 15);
    tokenDistribution[4] = PriceBand(100001, 120, 20);
    tokenDistribution[5] = PriceBand(1000001, 60, 25);
    tokenDistribution[6] = PriceBand(10000001, 30, 30);
    tokenDistribution[7] = PriceBand(100000001, 0, 0);
  }

  function buy(uint256 _amount, string memory _coindId) public {
    require(addressUserMapping[msg.sender] == 0, "Address Already Active");
    uint16 tokensToTransfer;
    uint8 price;

    if (userCount >= tokenDistribution[7].userCount) {
      tokensToTransfer = tokenDistribution[7].mokaToken;
      price = tokenDistribution[7].price;
    } else if (userCount >= tokenDistribution[6].userCount) {
      tokensToTransfer = tokenDistribution[6].mokaToken;
      price = tokenDistribution[6].price;
    } else if (userCount >= tokenDistribution[5].userCount) {
      tokensToTransfer = tokenDistribution[5].mokaToken;
      price = tokenDistribution[5].price;
    } else if (userCount >= tokenDistribution[4].userCount) {
      tokensToTransfer = tokenDistribution[4].mokaToken;
      price = tokenDistribution[4].price;
    } else if (userCount >= tokenDistribution[3].userCount) {
      tokensToTransfer = tokenDistribution[3].mokaToken;
      price = tokenDistribution[3].price;
    } else if (userCount >= tokenDistribution[2].userCount) {
      tokensToTransfer = tokenDistribution[2].mokaToken;
      price = tokenDistribution[2].price;
    } else if (userCount >= tokenDistribution[1].userCount) {
      tokensToTransfer = tokenDistribution[1].mokaToken;
      price = tokenDistribution[1].price;
    } else {
      tokensToTransfer = tokenDistribution[0].mokaToken;
      price = tokenDistribution[0].price;
    }

    if (price > 0) {
      require(_amount >= price, "Token Amount Incorrect");
      require(stablecoinContracts[_coindId] != address(0), "Stablecoin Address Invalid");
      bool successPayment = IERC20(stablecoinContracts[_coindId]).transferFrom(msg.sender, owner(), _amount * uint256(10 ** stablecoinDecimals[_coindId]));
      require(successPayment, "Payment Transfer Failed");
    }

    bool success = mokaTokenContract.transfer(msg.sender, tokensToTransfer * uint256(10 ** 18));
    require(success, "Moka Token Transfer Failed");
    addressUserMapping[msg.sender] = userCount + 1;
    userCount = userCount + 1;
    emit userJoined(userCount, msg.sender);
  }

  function setAllowedStableCoins(string[] memory _coins, address[] memory _contracts, uint8[] memory _decimals) public onlyOwner {
    require(_coins.length == _contracts.length, "Array Lengths Incorrect");

    //clear current stablecoin list
    for (uint i = 0; i < acceptedStablecoins.length; i++) {
      delete stablecoinContracts[acceptedStablecoins[i]];
      delete stablecoinDecimals[acceptedStablecoins[i]];
    }

    //set new stablecoin list
    for (uint i = 0; i < _coins.length; i++) {
      stablecoinContracts[_coins[i]] = _contracts[i];
      stablecoinDecimals[_coins[i]] = _decimals[i];
    }

    acceptedStablecoins = _coins;
  }

  function getAcceptedStablecoins() public view returns (string[] memory) {
    return acceptedStablecoins;
  }

  function getCurrentPriceBand() public view returns (uint16 tokens, uint8 price) {
    if (userCount >= tokenDistribution[7].userCount) {
      tokens = tokenDistribution[7].mokaToken;
      price = tokenDistribution[7].price;
    } else if (userCount >= tokenDistribution[6].userCount) {
      tokens = tokenDistribution[6].mokaToken;
      price = tokenDistribution[6].price;
    } else if (userCount >= tokenDistribution[5].userCount) {
      tokens = tokenDistribution[5].mokaToken;
      price = tokenDistribution[5].price;
    } else if (userCount >= tokenDistribution[4].userCount) {
      tokens = tokenDistribution[4].mokaToken;
      price = tokenDistribution[4].price;
    } else if (userCount >= tokenDistribution[3].userCount) {
      tokens = tokenDistribution[3].mokaToken;
      price = tokenDistribution[3].price;
    } else if (userCount >= tokenDistribution[2].userCount) {
      tokens = tokenDistribution[2].mokaToken;
      price = tokenDistribution[2].price;
    } else if (userCount >= tokenDistribution[1].userCount) {
      tokens = tokenDistribution[1].mokaToken;
      price = tokenDistribution[1].price;
    } else {
      tokens = tokenDistribution[0].mokaToken;
      price = tokenDistribution[0].price;
    } 
  }
}
