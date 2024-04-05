// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Demo{
    address public immutable owner;
    address[] public addrs;

    // mapping (address => string) erc20Coin;
    Token tt;

    constructor(){
        owner = msg.sender;
    }

    event Deposit(address sender,uint256 amount);
    event Withdraw(uint256 amount);

    modifier onlyOwner(){
        require(msg.sender == owner,"not owner");
        _;
    }

    receive() external payable {
       deposit();
    }

    function withdraw() external onlyOwner{
       emit Withdraw(address(this).balance);
       
       for(uint8 i=0;i<addrs.length;i++){
           tt = Token(addrs[i]);
           tt.transfer(msg.sender, tt.balanceOf(address(this)));
       }
       selfdestruct(payable (msg.sender));
    }

    uint256 public num ;
    function deposit() public payable {
        num = 10001;
        emit Deposit(msg.sender, msg.value);
    }

    function addCoin(address _addr) public {
        require(_addr != address(0),"invalid address");
        addrs.push(_addr);
    }

    function getBalance(address _addr) public returns(uint256){
        if(_addr == address(0)){
            return address(this).balance;
        }
        tt = Token(_addr);
        return tt.balanceOf(address(this));
    }

}


contract Test{
    // event Log(address addr1,address addr2);
    receive() external payable {}
    function send(address payable _addr,address contractAddr) public{
        Token tt = Token(contractAddr);
        tt.transferFrom(msg.sender,_addr , 10**18);
        // emit Log(msg.sender,tx.origin);
    } 
}

interface Token {
    // function _transfer(address from, address to, uint256 value) external ;
    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function balanceOf(address account) external view returns (uint256);
}

