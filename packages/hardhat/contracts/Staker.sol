// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {

  ExampleExternalContract public exampleExternalContract;

  mapping(address => uint256) public balances;

  //Staking threshold
  uint256 public constant threshold = 1 ether;

  //Staking deadline
  uint256 public deadline = block.timestamp + 3 hours;

  //Boolean set if threshold is not reached by the deadline
  bool public openForWithdraw;

  //EVENTS
  /// Emit when stake() is called
  event Stake(address sender, uint256 value);

  // MODIFIERS
  /// Modifier that checks whether the required deadline has passed

  modifier deadlinePassed(bool requireDeadlinePassed){
    uint256 timeRemaining = timeLeft();
    if (requireDeadlinePassed){
      require(timeRemaining <= 0, "Deadline has not been passed yet");
    } else {
      require(timeRemaining > 0, "Deadline is already passed");
    }
    _;
  }

  /// Modifier that checks whether the external contract is completed
  modifier stakingNotCompleted(){
    bool completed = exampleExternalContract.completed();
    require(!completed, "Staking period has completed");
    _;
  }

  constructor(address exampleExternalContractAddress) public {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  //  ( make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )
  

  function stake() public payable deadlinePassed(false) stakingNotCompleted {
    // update the sender's balance
    balances[msg.sender] += msg.value;

    // emit Stake event to nootify the UI
    emit Stake(msg.sender, msg.value);
  }

  // After some `deadline` allow anyone to call an `execute()` function
  //  It should either call `exampleExternalContract.complete{value: address(this).balance}()` to send all the value

function execute() public stakingNotCompleted{
  uint256 contractBalance = address(this).balance;
  if (contractBalance >= threshold) {
    // If the `threshold` is met, send the balance to the externalContract 
    exampleExternalContract.complete{value: contractBalance}();
  } else{
    // if the `threshold` was not met, allow everyone to call a `withdraw()` function
    openForWithdraw = true;
  }

}

  // Add a `withdraw()` function to let users withdraw their balance

function withdraw(address payable _to) public deadlinePassed(true) stakingNotCompleted {
  // check the amount staked did not reach the threshold by the deadline
  require(openForWithdraw, "Not open for withdraw");

  // get the sender balance
  uint256 userBalance = balances[msg.sender];

  // Check if the sender has a balance to withdraw
  require(userBalance > 0, "userBalance is 0"); 

  //reset the sender's balance
  balances[msg.sender] = 0;

  // btransfer sender's balance to the `_to` address
  (bool sent, ) = _to.call{value: userBalance}("");

  // Check transfer was successful
  require(sent, "Failed to send to address");

}
  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend

function timeLeft() public view returns (uint256) {
  if (block.timestamp >= deadline) {
    return 0;
  }else{
    return deadline - block.timestamp;
  }
}


  // Add the `receive()` special function that receives eth and calls stake()
  receive() external payable {
    stake();
  }

}
