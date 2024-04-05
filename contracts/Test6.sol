// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Demo {
    function demoAssembly1(uint256 _x, uint256 _y)
    public
    pure
    returns (uint256){
        assembly {
            let result := add(_x, _y)
            mstore(0x1, result)
            mstore(0x0, 7)
            return(0x0, 60)
        }
    }

    function demoAssembly12(uint256 _x, uint256 _y)
    public
    pure
    returns (uint256){
        assembly {
            let result := add(_x, _y)
            mstore(0x1, result)
            mstore(0x0, 7)
            return(0x0, 60)
        }
    }

    function demoAssembly11(uint256 _x, uint256 _y)
    public
    pure
    returns (uint256){
        uint256 result;
        assembly {
            result := add(_x, _y)
            mstore(0x90, result)
            // return(0x0, 32)
        }
        return result;
    }

    function demoAssembly2()
    public
    pure
    returns (string memory )
    {
        string memory str;
        assembly{
            str := mload(0x40)
            let value := 'edison'
            mstore(str,6)
            mstore(add(str,0x20),value)
            mstore(0x40,add(mload(0x40),0x40))
        }
        return str;
    }

    function demoAssembly5()
    public
    pure
    returns (string memory )
    {
        //0x656469736f6e6572656469736f6e6572656469736f6e6572656469736f6e6572
        string memory str;
        assembly{
            str := mload(0x40)
            let value := 'edisoneredisoneredisoneredisoner'
            mstore(str,32)
            mstore(add(str,0x20),value)
            mstore(add(str,0x40),'a')
            // mstore()
            mstore(0x40,add(mload(0x40),0x60))
            // return (add(str,0x21),35)
        }
        return str;
    }

    function demoAssembly3()
    public
    pure
    returns (string memory str,string memory str1,uint256 local,uint256,uint256)
    {
        // string memory str;
        uint256 localaa;
        uint256 local1;
        assembly{
            // mstore(str , 6)
            // mstore(add(str,0x20) , 'edison')
            // local := str

            // localaa := local
            // mstore(localaa,120)
            localaa := 120

            mstore(str1 , 6)
            mstore(add(str1,0x20) , 'tigers')
            local1 := str1
            mstore(0x40,0xa0)
        }
        return (str,str1,local,local1,localaa);
    }

    function demoAssembly4()
    public
    pure
    returns (bytes1[]  memory,uint256 )
    // returns(uint256)
    {
       bytes1[] memory arr = new bytes1[](3);
    //    = new bytes1[](3);
    //    arr[0] = 'a';
    //    arr[1] = 'b';
    //    arr[2] = 'c';
       uint256 local;
       assembly{
        //    arr := mload(0x40)
        //    mstore(mload(0x40),3)
        //    mstore(add(mload(0x40),0x20),'a')
        //    mstore(add(mload(0x40),0x40),'b')
        //    mstore(add(mload(0x40),0x60),'c')
        //    local := arr
        //    mstore(0x40,add(mload(0x40),0x80))
         mstore(add(arr,0x00),2)
         mstore(add(arr,0x20),'d')
         mstore(add(arr,0x40),'e')
         mstore(add(arr,0x60),'f')
       }
       return (arr,local);
    }



     function uintToBytes32(uint256 u) public pure returns(bytes32){
        return bytes32(u);
    }

    // function test()public pure returns(bytes32,bytes16){
    //     bytes16 str = "smile";
    //     bytes32 str1 = bytes32(str);
    //     return (str1,str);
    // }

    //  function test1()public pure returns(bytes4,bytes2){
    //     uint16 str = 0x0019;
    //     uint32 str1 = uint32(str);
    //     return (bytes4(str1),bytes2(str));
    // }
}