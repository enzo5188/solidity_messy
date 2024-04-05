// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

contract MemoryLane {
    
    function demoAssembly(uint8 _x, uint8 _y)
    public
    pure
    returns (uint256)
    {
    assembly {
        let result := add(_x, _y)
        mstore(0x0, result)
        return(0x0, 2)
    }
   }
}