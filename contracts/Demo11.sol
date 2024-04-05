// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
/**
* index 怎么实现？
*/
contract ToDoList{
    struct Todo{
        string name;
        bool isComplete;
    }
    Todo[] public list;

    function create(string memory name_) public{
        list.push(
            Todo({
               name:name_,
               isComplete:false
            })
        );
    } 

    function modiName1(uint256 index_,string memory name_) public {
        list[index_].name = name_;
    }

    function modiName2(uint256 index_,string memory name_) public {
        Todo storage todo = list[index_];
        todo.name = name_;
    }

    function modiStatus1(uint256 index_,bool status_) public{
        list[index_].isComplete = status_;
    }

    function modiStatus2(uint256 index_) public{
        list[index_].isComplete = !list[index_].isComplete;
    }

    function get1(uint256 index_) public view returns(string memory name_,bool isComplete){
        Todo storage todo = list[index_];
        return (todo.name,todo.isComplete);
    } 

    function get2(uint256 index_) public view returns(string memory name_,bool isComplete){
        Todo memory todo = list[index_];
        return (todo.name,todo.isComplete);
    } 

}