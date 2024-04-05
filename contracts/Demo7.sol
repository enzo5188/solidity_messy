// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
contract Demo{   

    function test() public pure returns(uint8){
        uint8 num = 255;
        unchecked{
            return num + 3;
        }     
    }       
}