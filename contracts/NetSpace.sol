// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
///@title 一个关于注释的小Demo
// import "./Version.sol" as version;
contract Demo {
    uint256 num;
    uint256 num1;

    /// @notice 将_num存储到状态变量num
    function set(uint256 _num) public{
        num = _num;
    }
    
    /**
     * @notice 获取状态变量并将值返回aaaa
     */
    function get() public view returns(uint256){
        return num;
    }

    function test() public pure returns(uint256){
        return 2**3**2;
    }
        
}

contract Demo1 {
    uint256 num;
    uint256 num1;

    /// @notice 将_num存储到状态变量num
    function set(uint256 _num) public{
        num = _num;
    }
    
    /**
     * @notice 获取状态变量并将值返回aaaa
     */
    function get() public view returns(uint256){
        return num;
    }

    function test() public pure returns(uint256){
        return 2**3**2;
    }
        
}