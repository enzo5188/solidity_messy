// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
contract Cat{
    function eat() public pure returns(string memory){
        return "Cat eat fish!!";
    }
}

contract Dog{
    function eat() public pure returns(string memory){
        return "Dog eat bond!!";
    }
}

interface Ainmal {
    function eat() external  pure returns(string memory);
}

contract Demo{
    function eat(address addr) public pure returns(string memory){
        Ainmal ainmal = Ainmal(addr);
        return ainmal.eat();
    }
}