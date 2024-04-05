// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract Demo {
    
    // 第一种方式 将数字0-9转换成string 0-90
    function toStr(uint8 value) public pure  returns(string memory){
        require(value < 10,"error value");
        bytes memory alphabet = "0123456789";
        bytes1 b1 = alphabet[value];
        bytes memory bs = new bytes(1);
        bs[0] = b1;
        return string(bs);
    }

    // 第一种方式 将数字0-9转换成string 0-9
    function toStr1(uint256 value) public pure returns(string memory){
       bytes memory alphabet = "0123456789abcdef";
       bytes32 data = bytes32(value);
       bytes memory bts = new bytes(1);
       uint256 index = data.length -1 ;
       bts[0] = alphabet[uint8(data[index] & 0x0f)];
       return string(bts);
    }
    
    // 借助toStr1或者toStr方法，将任意数字转换成字符串
    function toStr2(uint256 value) public pure returns(string memory str){
        if(value == 0)  return "0";
        while(value != 0){
           uint256 r = value % 10;
           value = value / 10;
           str = string.concat(toStr1(r),str);
        }
    }
}