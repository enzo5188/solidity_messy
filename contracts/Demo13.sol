// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Crowdfunding{
    address public immutable beneficiary;
    uint256 public immutable fundingGoal;
     
    uint256 public fundingAmount;
    mapping (address=> uint256) public funders;

    mapping (address => bool) funderInserted;
    address[] public  funderKeys;

    bool public validable = true;

    constructor(address beneficiary_,uint256 fundingGoal_){
        beneficiary = beneficiary_;
        fundingGoal = fundingGoal_;
    }

    function contribution() public payable {
        require(validable,"Crowdfunding has been closed");
        fundingAmount += msg.value;
        funders[msg.sender] += msg.value;
        // 检查
        if(!funderInserted[msg.sender]){
            // 修改检查条件
            funderInserted[msg.sender] = true;
            //执行操作
            funderKeys.push(msg.sender);
        }
    }

    function close() public returns(bool){   
        // 检查     
        if(fundingAmount< fundingGoal){
             return false;
        }
        uint256 amount = fundingAmount;
        // 修改检查条件
        validable = false;
        fundingAmount = 0;
        //执行操作
       payable (beneficiary).transfer(amount);
       return true;
    }

    function fundersLength() public view returns(uint256){
        return funderKeys.length;
    }

}