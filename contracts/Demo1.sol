// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
contract Demo {
    address public immutable leader;
    uint8 public step;
    string private constant UNKNOW = unicode"未知错误，请联系相关人员";

    event Log(string functionName, address addr, uint256 amount, bytes data);
    event Step(uint8);

    constructor(address leader_) {
        require(leader_ != address(0), unicode"领导地址错误");
        leader = leader_;
    }

    modifier OnlyLeader() {
        require(msg.sender == leader, "only leader");
        _;
    }

    modifier NotLeader() {
        require(msg.sender != leader, "cant leader");
        _;
    }

    /// @notice 自定义错误
    /// @dev aaaaa
    error MyError(string notice);

    function hello(string calldata content) public OnlyLeader returns (bool) {
        if (step != 0) {
            revert(UNKNOW);
        }

        if (!review(content, unicode"同志们好")) {
            revert MyError(unicode"必须说同志们好");
        }
        ++step;
        emit Step(step);
        return true;
    }

    function helloRsp(string calldata content) public NotLeader returns (bool) {
        if (step != 1) {
            revert(UNKNOW);
        }

        if (!review(content, unicode"领导好")) {
            revert MyError(unicode"必须说领导好");
        }
        ++step;
        emit Step(step);
        return true;
    }

    function confort(
        string calldata content
    ) public payable OnlyLeader returns (bool) {
        if (step != 2) {
            revert(UNKNOW);
        }

        if (!review(content, unicode"同志们辛苦了")) {
            revert MyError(unicode"必须说同志们辛苦了");
        }

        if (msg.value < 1 ether) {
            revert(unicode"给钱不能少于1 ether");
        }

        ++step;
        emit Step(step);
        emit Log("confort", msg.sender, msg.value, msg.data);
        return true;
    }

    function confortRep(
        string calldata content
    ) public NotLeader returns (bool) {
        if (step != 3) {
            revert(UNKNOW);
        }

        if (!review(content, unicode"为人名服务")) {
            revert MyError(unicode"必须说为人名服务");
        }
        ++step;
        return true;
    }

    function destruct() public OnlyLeader {
        if (step != 4) {
            revert(UNKNOW);
        }
        selfdestruct(payable(leader));
        emit Log("destruct", msg.sender, 0, msg.data);
    }

    function review(
        string calldata content,
        string memory correctContent
    ) internal pure returns (bool) {
        if (
            keccak256(abi.encodePacked(content)) ==
            keccak256(abi.encodePacked(correctContent))
        ) {
            return true;
        }
        return false;
    }

    fallback() external payable {
        emit Log("receive", msg.sender, msg.value, msg.data);
    }

    receive() external payable {
        emit Log("receive", msg.sender, msg.value, "");
    }
}
