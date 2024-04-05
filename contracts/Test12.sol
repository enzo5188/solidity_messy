// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract For {
    function test1(uint256 _x) external pure returns (uint256 temp) {
        uint256 i = 6;
        while (i <= _x) {
            temp += i;
            i++;
        }
    }

    function test2(uint256 _x) external pure returns (uint256 temp) {
        uint256 i = 6;
        do {
            temp += i;
            i++;
        } while (i <= _x);
    }
}