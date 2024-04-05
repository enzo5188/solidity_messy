// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

library Search {
    function indexOf(uint8[] memory self, string memory value)
        internal
        pure
        returns (string memory){
            self[0] = 6;
            bytes(value)[0]='p';
            // value = 'piger';
            return value; 
        }
}

contract C {
    using Search for uint8[];
    uint8[] public data;

    function replace(string memory from) public returns(string memory,string memory){
        data.push(3);
        data.push(4);
        data.push(5);
        return (from,data.indexOf(from));
        // return from;
    }


    function test() public pure returns(string memory,string memory){
        string memory str = "tiger";
        string memory str1 = str;
        str = "piger";
        // bytes(str)[0] = 'p';
        return(str,str1);
    }
}