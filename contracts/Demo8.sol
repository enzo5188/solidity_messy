// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
contract Demo{
   string public str = "abc";
   //借助bytes 实现string类型 push,注意：bytes.push(x) 跟 bytes.pop()函数没有返回值
   function strPush() public{
      bytes(str).push("d");
   }
   //借助bytes 实现string类型pop,注意：bytes.push(x) 跟 bytes.pop()函数没有返回值
   function strPop() public{
      bytes(str).pop();
   }
   // 无须借助bytes 
   function strDelete() public{
      delete str;
   }
   //借助bytes 实现string类型delete index
   function strDeleteInde() public{
      delete bytes(str)[0];
   }
   //借助bytes 实现string类型slice(切片)
   function strSlice(string calldata strParam) public pure returns(string memory){
     bytes memory bts = bytes(strParam)[0:5];
     return string(bts);
   }
}