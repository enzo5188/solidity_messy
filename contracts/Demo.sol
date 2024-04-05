// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.8;

// 使用用户定义的值类型表示一个18位小数，256位宽的定点类型。
type UFixed8x1 is uint8;

/// 一个在UFixed8x1上进行定点操作的最小库。
library FixedMath {
    uint8 constant multiplier = 10;

    /// 将两个UFixed8x1的数字相加。溢出时将返回，依靠uint8的算术检查。
    function add(UFixed8x1 a, UFixed8x1 b) internal pure returns (UFixed8x1) {
        return UFixed8x1.wrap(UFixed8x1.unwrap(a) + UFixed8x1.unwrap(b));
    }
    /// 将UFixed8x1和uint8相乘。溢出时将返回，依靠uint8的算术检查。
    function mul(UFixed8x1 a, uint8 b) internal pure returns (UFixed8x1) {
        return UFixed8x1.wrap(UFixed8x1.unwrap(a) * b);
    }
    /// 对一个UFixed8x1类型的数字相下取整。
    /// @return 不超过 `a` 的最大整数。
    function floor(UFixed8x1 a) internal pure returns (uint8) {
        return UFixed8x1.unwrap(a) / multiplier;
    }
    /// 将一个uint8转化为相同值的UFixed8x1。
    /// 如果整数太大，则恢复计算。
    function toUFixed8x1(uint8 a) internal pure returns (UFixed8x1) {
        return UFixed8x1.wrap(a * multiplier);
    }
}

contract Demo{
    function toUFixed8x1(uint8 num) public pure returns(UFixed8x1){
        return FixedMath.toUFixed8x1(num);
    }

    function floor(UFixed8x1 num) public pure returns(uint8){
        return FixedMath.floor(num);
    }

    function add(UFixed8x1 a, UFixed8x1 b) public pure returns(UFixed8x1){
        return FixedMath.add(a,b);
    }

    function mul(UFixed8x1 a, uint8 b) public pure returns(UFixed8x1){
        return FixedMath.mul(a,b);
    }    
}