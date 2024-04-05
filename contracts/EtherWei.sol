// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
contract Demo{
    event Log(string functionName,uint256 amount);
    uint256 amount = 1;
    uint256 public param;

    function add() public view  returns(uint256){
       return amount + 1 wei;
    }

    function add(uint256 num) public view  returns(uint256){
    //    return amount + num ether;// 错误示例
       return amount + num * 1 ether;
    }

    function verify() public pure  returns(bool,bool,bool){
        bool onewei = 1 wei == 1;
        bool onegwei = 1 gwei == 10 ** 9;
        bool oneether = 1 ether == 10 ** 18;

        return (onewei,onegwei,oneether);
    }

    function deposit() public payable {
        emit Log("deposit",msg.value);
        param = abi.decode(msg.data[4:], (uint256));
    }

    // fallback() external payable { 
    //     amount = 2;
    //     emit Log("fallback",msg.value);
    // }

    fallback(bytes calldata input) external payable returns (bytes memory output){ 
        param = abi.decode(input[4:], (uint256));
        return input;

    }

    receive() external payable { 
        amount = 2;
        emit Log("receive",msg.value);
    }
}

contract Test{

    event Log(string functionName,uint256 amount);
    
    fallback() external payable { 
        emit Log("fallback",msg.value);
    }

    receive() external payable { 
        emit Log("receive",msg.value);
    }

    function sendEther(address addr) public returns (bool){
        bool result  = payable(addr).send(1 ether);
        return result;
    } 

    function transferEther(address addr) public{
        payable(addr).transfer(1 ether);
    } 

    function callEther(address addr) public returns (bool){
       (bool result,) = payable(addr).call{value: 1 ether}(abi.encodeWithSignature("deposit()",10 ether));
       return result;
    } 


}
