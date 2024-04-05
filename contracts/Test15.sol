// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract Cat {
    mapping (uint256 => string)  public map;

    function test() public {
        map[1] = 'str1';
        map[1] = 'str2';
    }
}

