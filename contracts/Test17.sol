// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

interface Base
{
    function foo()  external;
}

contract Base1 is Base
{
    function foo() virtual override  public {}
}

abstract contract Base2 is Base
{
    // function foo() virtual public {}
    function foo() virtual override  public {}
}

contract Inherited is Base1, Base2
{
    // 继承自两个基类合约定义的foo(), 必须显示的指定 override
    function foo() public override(Base1, Base2) {}
}