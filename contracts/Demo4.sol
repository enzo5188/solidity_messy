// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

contract Demo{
    int8 public num = -8;

    function test() public view  returns(bytes32){
        return bytes32(int256(num));
    }
}