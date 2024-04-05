// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract WETH{
    string private  NAME = "SSS";
    string public constant name = "WrappedETH";
    string public constant symbol = "WETH";
    uint8 public constant decimals = 18;
    mapping (address => uint256) internal balances;
    mapping (address => mapping (address=>uint256)) public allowance;

    event Transfer(address indexed _from,address indexed  _to,uint256 _amount);
    event Approval(address indexed  _owner,address indexed  _spender,uint256 _amount);
    event Deposit(address indexed  _from,uint256 _amount);
    event Withdraw(address indexed  _to,uint256 _amount);


    receive() external payable {
        deposit();
    }

    fallback() external {

    }

    function deposit() public payable returns(bool result){
        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
        return true;
    }

    function withdraw(address _to,uint256 _amount) public returns(bool result){
        require(_to != address(0) , "error address");
        require(balances[msg.sender] >= _amount,"error amount");
        balances[msg.sender] -= _amount;
        payable(_to).transfer(_amount);
        emit Withdraw(_to, _amount);
        return true;
    }

    function totalSupply() public view returns(uint256 amount){
        return address(this).balance;
    }

    function balanceOf(address _addr) public view returns(uint256 amount){
        require(_addr != address(0) , "error address");
        return balances[_addr];
    }

    function transfer(address _to,uint256 _amount) public returns(bool result){
        return transferFrom(msg.sender,_to,_amount);
    }

    function transferFrom(address _owner,address _to,uint256 _amount) public returns(bool result){
        require(_owner != address(0) , "error address");
        require(_to != address(0) , "error address");
        if(msg.sender != _owner){
            require(allowance[_owner][msg.sender] >= _amount,"not allowance"); 
            allowance[_owner][msg.sender] -= _amount;
        }
        require(balances[_owner] >= _amount,"error amount");
        balances[_owner] -= _amount;
        balances[_to] += _amount;
        emit Transfer(_owner, _to, _amount);
        return true;
    }

    function approve(address _spender,uint256 _amount) public returns(bool result){
        require(_spender != address(0) , "error address");
        allowance[msg.sender][_spender] = _amount; 
        return true;
    }

}


