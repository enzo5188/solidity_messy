// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
/**
* index 怎么实现？
*/
contract ToDoList{
    struct Todo{
        uint256 index;
        string name;
        bool isComplete;
    }
    Todo[] public list;
    uint256 index;

    function create(string memory name_) public{
        list.push(
            Todo({
               index:++index,
               name:name_,
               isComplete:false
            })
        );
    } 

    function modiName1(uint256 index_,string memory name_) public {
        Todo storage todo;
        for(uint256 i = 0;i< list.length;i++){
            if(list[i].index == index_){
                todo = list[i];
                todo.name = name_;
                break ;
            }
        }
    }

    function modiStatus1(uint256 index_,bool status_) public{
        Todo storage todo;
        for(uint256 i = 0;i< list.length;i++){
            if(list[i].index == index_){
                todo = list[i];
                todo.isComplete = status_;
                break ;
            }
        }
    }

    function modiStatus2(uint256 index_) public{
        Todo storage todo;
        for(uint256 i = 0;i< list.length;i++){
            if(list[i].index == index_){
                todo = list[i];
                todo.isComplete = !todo.isComplete;
                break ;
            }
        }
    }

    function get1(uint256 index_) public view returns(string memory name_,bool isComplete){
        Todo storage todo;
        for(uint256 i = 0;i< list.length;i++){
            if(list[i].index == index_){
                todo = list[i];
                name_ = todo.name;
                isComplete = todo.isComplete;
                break ;
            }
        }
    } 

    function get2(uint256 index_) public view returns(string memory name_,bool isComplete){
        Todo memory todo;
        for(uint256 i = 0;i< list.length;i++){
            if(list[i].index == index_){
                todo = list[i];
                name_ = todo.name;
                isComplete = todo.isComplete;
                break ;
            }
        }
    } 

}