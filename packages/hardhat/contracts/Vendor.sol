pragma solidity 0.8.4;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {

  YourToken public yourToken;
  uint256 public constant tokensPerEth = 100;
  
  //EVENTS
  event BuyTokens(address buyer, uint256 amountOfEth, uint256 amountOfTokens);

  event SellTokens(address seller, uint256 amountOfTokens, uint256 amountOfETH);

  constructor(address tokenAddress) {
    yourToken = YourToken(tokenAddress);
  }

  // ToDo: create a payable buyTokens() function:
  function buyTokens() public payable returns (uint256 tokenAmount) {
    require(msg.value > 0, 'ETH used to buy token must be greater than 0');

    uint256 tokenToBuy = msg.value * tokensPerEth;

    // check if the Vendor Contract has enough amount of tokens for the transaction
    uint256 vendorBalance = yourToken.balanceOf(address(this));
    require(vendorBalance >= tokenToBuy, 'Vendor has not enough tokens to sell');

    // Transfer token to the msg.sender
    bool success = yourToken.transfer(msg.sender, tokenToBuy);
    require(success, 'Failed to transfer token to user');

    emit BuyTokens(msg.sender, msg.value, tokenToBuy);

    return tokenToBuy;
  }

  // ToDo: create a withdraw() function that lets the owner withdraw ETH

    function withdraw() public onlyOwner {
    uint256 ethToWithdraw = address(this).balance;
    require(ethToWithdraw > 0, 'No ETH to withdraw');

    payable(msg.sender).transfer(ethToWithdraw);
  }

  // ToDo: create a sellTokens() function:


    function sellTokens(uint256 amount) public {
     uint256 theAmount = amount/tokensPerEth;
    yourToken.transferFrom(msg.sender, address(this), amount);
     (bool sent, bytes memory data) = msg.sender.call{value: theAmount}("");
    emit SellTokens(msg.sender, amount, theAmount);
  }
    
}
