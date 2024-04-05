// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
contract Demo{

    uint256 public  num ;

    function test(address addr) public view returns(uint256 ){
        return addr.balance;
    }

    function set(uint256 _num,address _addr) public returns(uint256){
       num = _num;
       return _addr.balance;
    }
}