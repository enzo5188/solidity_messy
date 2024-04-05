// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;


contract modifysample {
    
    function test() public pure returns(bytes memory by,uint8 ){
        uint8 b1 ;
        assembly{
            by := mload(0x40)
            mstore(by,32)
            mstore(add(by,0x20),'abcdefabcdefabcdefabcdefabcdefab')

            // mstore(add(by,0x40),byte(0,mload(add(by,0x20))))

            mstore(0x40,add(by,0x40))
            // byte(0, mload(add(by, 96)))
            b1 := byte(0,mload(add(by,0x20)))
        }

        bytes32 hash = keccak256(abi.encodePacked(byte(0x19), byte(0), address(this), msg.value, nonce, payload));
        keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _msgHash)
        return (by,b1);
    }
   
}