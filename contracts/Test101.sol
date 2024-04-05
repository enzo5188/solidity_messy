// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract Test {
constructor(){
    
}

    function test1() public pure returns(uint8){
        uint8 i = 5;
        uint8 j = 6;
        unchecked{return i-j;}    
    }

    function test2() public pure returns(uint8){
        uint8 i = 255;
        uint8 j = 1;
        unchecked{return i+j;}    
    }
    
    function test3() public pure returns(bool){

        int8 x = type(int8).min;
        unchecked { 
            if(-x == x){
                return true; 
            }
        }
        return false;

        // return (type(int8).min,type(int8).max);    
    }

    function test4() public pure returns(bytes2){
        bytes2 u = "ab";
        return u << 1;
    }

    uint256 public a = 20;
    uint256 public b = 10;

    function test5() public pure returns (int8) {
        int8 i = 3;
        return ~i;
    }
}