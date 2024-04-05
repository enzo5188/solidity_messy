// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract Test1 {
    address public owner = msg.sender;

    function setOwner(address _owner) public {
        require(msg.sender == owner, "now owner");
        owner = _owner;
    }
}

contract Test2 {
    address public owner = msg.sender;
    uint256 public value = msg.value;
    uint256 public x;
    uint256 public y;

    constructor(uint256 _x, uint256 _y) {
        x = _x;
        y = _y;
    }
}

// contract Proxy {
//     function depolyTest1() external {
//         new Test1();
//     }

//     function depolyTest2() external payable {
//         new Test2(1, 2);
//     }
// }

// assembly 部署
contract Proxy {
    event Depoly(address);

    // fallback() external payable {}

    function depoly(bytes memory _code)
        external
        payable
        returns (address adds)
    {
        assembly {
            // create(v,p,n);
            // v 是 发送的ETH值
            // p 是 内存中机器码开始的位置
            // n 是 内存中机器码的大小
            // msg.value 不能使用，需要用 callvalue()
            adds := create(callvalue(), add(_code, 0x20), mload(_code))
        }

        require(adds != address(0), "Depoly Failed");
        emit Depoly(adds);
    }

    // 跳用
    function execute(address _target, bytes memory _data) external payable {
        (bool success, ) = _target.call{value: msg.value}(_data);
        require(success, "Failed");
    }
}

contract Helper {
    // 生成 type(contract).creationCode
    function getBytescode1() external pure returns (bytes memory bytecode) {
        bytecode = type(Test1).creationCode;
    }

    // 生成构造函数带有参数的 bytecode，参数连接后面就可以了
    function getBytescode2(uint256 _x, uint256 _y)
        external
        pure
        returns (bytes memory)
    {
        bytes memory bytecode = type(Test2).creationCode;
        // abi 全局变量
        return abi.encodePacked(bytecode, abi.encode(_x, _y));
    }

    // 调用合约方法的calldata，使用 abi.encodeWithSignature
    function getCalldata(address _owner) external pure returns (bytes memory) {
        return abi.encodeWithSignature("setOwner(address)", _owner);
    }
}