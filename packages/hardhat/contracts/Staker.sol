// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;  //Do not change the solidity version as it negativly impacts submission grading

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {

  ExampleExternalContract public exampleExternalContract;

  // 跟踪用户余额
  mapping (address => uint256) public balances;

  uint256 public constant threshold = 0.01 ether;

  uint256 public deadline = block.timestamp + 60 seconds;

  bool public openForWithdraw = false;

  constructor(address exampleExternalContractAddress) {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  event Stake(address,uint256);

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  // ( Make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )

  function stake() payable public notCompleted  {
    balances[msg.sender] += msg.value;
    _tagComplete();
    emit Stake(msg.sender, msg.value);
  }


  // After some `deadline` allow anyone to call an `execute()` function
  // If the deadline has passed and the threshold is met, it should call `exampleExternalContract.complete{value: address(this).balance}()`

  function execute() public notCompleted {
    require(block.timestamp > deadline,"-----------no arrive deadline");

    _tagComplete();

    if(address(this).balance < threshold) {
      openForWithdraw = true;
    }

  }

  function _tagComplete() internal {
    if (block.timestamp < deadline && address(this).balance >= threshold) {
      exampleExternalContract.complete();
    }
  }


  // If the `threshold` was not met, allow everyone to call a `withdraw()` function


  // Add a `withdraw()` function to let users withdraw their balance
  function withdraw() public notCompleted {
    require(openForWithdraw,"----No refund allowed, please call Execute");
    uint256 _amount = balances[msg.sender];
    require(_amount > 0,"-----------------No refundable balance");
    balances[msg.sender] = 0;
    payable(msg.sender).transfer(_amount);
  }

  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
  function timeLeft() public view returns(uint256) {
    if (block.timestamp >= deadline) {
      return 0;
    }
    return deadline - block.timestamp;
  }


  modifier notCompleted() {
    require(!exampleExternalContract.completed(), "-----has completed");
    _;
  }


  // Add the `receive()` special function that receives eth and calls stake()
  fallback() external payable {}
    
  receive() external payable {
    balances[msg.sender] += msg.value;
    emit Stake(msg.sender, msg.value);
  }

}
