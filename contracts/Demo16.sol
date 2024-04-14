// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
contract Demo {
    uint256 public num;

    function getNum() public view returns (uint256) {
        return num;
    }

    function setNum(uint256 _num) public {
        num = _num;
    }
}
