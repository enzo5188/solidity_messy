// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Test{
    mapping (address => mapping (address => uint256)) map;

    function set() public {
        map[0x5B38Da6a701c568545dCfcB03FcB875f56beddC4][0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2] = 100;
        map[0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db][0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB] = 101;
    }
    

    function getDateFromLocal(bytes32 data) public view returns(uint256 b){
        assembly {
            // v 是长度是 32 bytes
            b := sload(data)
        }
    } 


    function mapLocation(address ads1, address ads2, uint256 slot) public pure returns (bytes32 local2) {
        
        bytes32 local1 = keccak256(abi.encodePacked(uint256(uint160(ads1)), slot));

        local2 = keccak256(abi.encodePacked(uint256(uint160(ads2)), local1));

        // return keccak256(abi.encodePacked(uint256(uint160(ads1)), slot));
    }
}