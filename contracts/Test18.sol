// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

// 定义一个名为 SafeIncrement 的合约
contract SafeIncrement {
    uint16 constant MAX_UINT16 = type(uint16).max; // uint128 类型的最大值

    function increaseBalance(uint8 value) public pure returns (uint16) {
        uint16 currentBalance = MAX_UINT16;
        unchecked {
            // 增加余额，但限制增量值在 uint128 类型的范围内
            currentBalance += value;
        }
        return currentBalance;
    }
}
