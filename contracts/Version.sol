// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;
// import {Demo as TT} from "./NetSpace.sol";
import {Demo,Demo1}  from "./NetSpace.sol";
contract Test{
    
    uint256 num;
    constructor(){
       num = test();
    }

    function test() public pure returns(uint256){
        return 2**3**2;
    }

    function getName() public pure returns(string memory){
        return type(Demo).name;
    }

    function callDemoTest() public  returns(uint256){
        Demo demo = new Demo();
        return demo.test();
    }

    function callDemo1Test() public  returns(uint256){
        Demo1 demo = new Demo1();
        return demo.test();
    }

    function getSelector() public pure returns(bytes4){
        return bytes4(keccak256('fallback()'));
    }

}

