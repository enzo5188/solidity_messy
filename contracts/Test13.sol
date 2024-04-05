// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

 abstract contract Base {
    uint x;
    constructor(uint x_) { x = x_; }
}

// 要么直接在继承列表中指定...
contract Derived1 is Base(7) {
    constructor() {}
}

// 或者通过派生构造函数的一个 "修改器"……
contract Derived2 is Base {
    constructor(uint y) Base(y * y) {}
}

// 或者将合约声明为abstract类型……
   contract Derived3 is Base(1) {
}

// 并让下一个具体的派生合约对其进行初始化。
// contract DerivedFromDerived is Derived3 {
//     constructor() Base(10 + 10) {}
// }