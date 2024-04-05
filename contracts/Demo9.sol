// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
contract Demo{
    mapping (address => uint256) balances; 
    mapping (address => bool) insertedKeys;
    address[] keys;
    function set(address addr_,uint256 amount_) public {
        balances[addr_] = amount_;
        // 1.检查
        if(!insertedKeys[addr_]){
            // 2.修改检查条件
            insertedKeys[addr_] = true;
            // 3.执行操作
            keys.push(addr_);
        }
    }
    // 遍历mapping，找出指定金额对应的地址
    function check(uint256 amount_)  public view returns(address){
        for (uint256 i = 0;i < keys.length;i++){
            if(amount_ == balances[keys[i]]){
                return keys[i];
            }
        }
        return address(0);
    }  
}
