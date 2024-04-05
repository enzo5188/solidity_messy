// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
// uint256 immutable num1 = 8;
contract Demo{
    uint256 public num;

    function get() public view returns(uint256){
        return num;
    }

    function set(uint256 _num) public{
        num = _num;
    }

    function selfDestruct() public {
       selfdestruct(payable (msg.sender));
    }

    function deposit() public payable {
        
    }
}