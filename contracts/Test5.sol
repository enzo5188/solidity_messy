// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import { UD60x18 } from "@prb/math/src/UD60x18.sol";
import "@prb/math/src/ud60x18/Conversions.sol"; 

contract Demo{
    function div(UD60x18 x, UD60x18 y) public pure returns (UD60x18 result){
        return  x.div(y);   
    }
    function mul(UD60x18 x, UD60x18 y) public pure returns (UD60x18 result) {
        return x.mul(y);         //18000000000000000000
    }
    function change1(uint256 num)  public pure returns (UD60x18 result){
      return  convert(num);
    }
    function change2(UD60x18 num)  public pure returns (uint256 result){
      return  convert(num);
    }

}
