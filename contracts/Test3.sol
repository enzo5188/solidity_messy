// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.0 <0.9.0;
contract A {
    struct S {
        uint128 a;
        uint128 b;
        uint[2] staticArray;
        uint[] dynArray;
    }

    uint x = 11;
    uint y = 22;
    S s;
    address addr = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
    mapping (uint => mapping (address => bool)) map;
    // mapping (address => bool) innerMap;
    uint[] array;
    string s1 = "smile";
    bytes b1 = "abc";

    function setData()public {
        // s = ()
        s.staticArray[0] = 101;
        s.staticArray[1] = 102;
        array.push(111);
        array.push(222);
        s.dynArray = array;
        s.a= 33;
        s.b= 44;    
        map[0][0x5B38Da6a701c568545dCfcB03FcB875f56beddC4] = false;
        map[1][0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2] = true;

        

    }

    function countLocal() public pure returns (bytes32){
        // arr.push(11);
        bytes32 arrLocal = bytes32(uint256(8));
        bytes memory bts = new bytes(arrLocal.length);
        for(uint256 i = 0 ; i < arrLocal.length ; i++){
            bts[i] = arrLocal[i];
        }
        return keccak256(bts);      
    }

    function mapLocation(uint256 index , uint256 slot) public pure returns (bytes32 local1) {
        local1 = keccak256(abi.encodePacked(index,slot));
    }

    function mapLocation(address ads, uint256 slot) public pure returns (bytes32 local1) {
        local1 = keccak256(abi.encodePacked(uint256(uint160(ads)),slot));
    }
   
    function uintToBytes32(uint256 u) public pure returns(bytes32){
        return bytes32(u);
    }

    function getDateFromLocal(bytes32 data) public view returns(uint256 b){
        assembly {
            // v 是长度是 32 bytes
            b := sload(data)
        }
    } 
}