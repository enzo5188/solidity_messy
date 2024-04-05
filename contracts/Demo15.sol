// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

 contract Demo{
        function test(uint256 num) public pure returns(uint256 ){
            return num+1;
        }
    }
    contract Call{
        function callTest(address _addr) public  returns(uint256){
            bytes memory sign = abi.encodeWithSignature("test(uint256)", 911);
            (,bytes memory data ) = address(_addr).call{value:0}(sign);
            uint256 num = abi.decode(data,(uint256));
            return num; // 912
        }
    }