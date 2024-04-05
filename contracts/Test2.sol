// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
contract Test2{
    string public str = "abcdefabcdefabcdefabcdefabcdefab";
    function uintToBytes32(uint256 u) public pure returns(bytes32){
        return bytes32(u);
    }
    function getDateFromLocal(bytes32 data) public view returns(uint256 b){
        assembly {
            // v 是长度是 32 bytes
            b := sload(data)
        }
    } 

    function getLocal() public pure returns(bytes32 ){
        bytes32 arrLocal = bytes32(uint256(0));
        bytes memory bts = new bytes(arrLocal.length);
        for(uint256 i = 0 ; i < arrLocal.length ; i++){
            bts[i] = arrLocal[i];
        }
        return keccak256(bts);
    }

}