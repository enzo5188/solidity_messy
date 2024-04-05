// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract DeployContract{
    uint256 num = 111;
    function getNum() public view returns(uint256){
        return num;
    }
}


contract Demo {
    // 获取即将部署的地址
    function getAddress(bytes memory bytecode, uint256 _salt)
        external
        view
        returns (address)
    {
        bytes32 hash = keccak256(
            abi.encodePacked(
                bytes1(0xff), // 固定字符串
                address(this), // 当前工厂合约地址
                _salt, // salt
                keccak256(bytecode) //部署合约的 bytecode
            )
        );
        return address(uint160(uint256(hash)));//0xA90B8E49Fa13E9C4EDF4411F1d5fe7ad04d26de9
    }

    function deploy(bytes memory bytecode, uint256 _salt)
        external
        returns (address)
    {
        address addr;
        require(bytecode.length != 0,"bytecode is zero");
        assembly{
            addr := create2(0,add(bytecode,0x20),mload(bytecode),_salt)
        }
        return addr;//0xA90B8E49Fa13E9C4EDF4411F1d5fe7ad04d26de9
    }
}