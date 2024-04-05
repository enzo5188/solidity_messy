// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Crowdfunding{
    struct Funder{
        address funder;
        uint256 amount;
    }

    address public immutable beneficiary;
    uint256 public immutable fundingGoal;
     
    uint256 public fundingAmount;
    Funder[] public funders;

    bool public validable = true;
    uint256 public deadline = block.timestamp + 1 seconds;

    constructor(address beneficiary_,uint256 fundingGoal_){
        beneficiary = beneficiary_;
        fundingGoal = fundingGoal_;
    }

    function getFundersIndex(address _addr) public view returns(uint256 index_){
        Funder storage funder;
        for(uint256 i = 0;i<funders.length;i++){
            funder = funders[i];
            if(_addr == funder.funder){
                return i;
            }
        }
        return funders.length;
    }

    function contribution() public payable {
        require(validable,"Crowdfunding has been closed");
        require(block.timestamp <= deadline,"Crowdfunding is finished");
        fundingAmount += msg.value;
        uint256 index = getFundersIndex(msg.sender);
        if(index == funders.length){
            funders.push(Funder({
                funder:msg.sender,
                amount:msg.value
            }));
        }else{
            funders[index].amount += msg.value;
        }
    }

    // 1.时间大于deadline 才可以关闭。
    // 2.如果募集资金大于等于目标金额 关闭之后将钱转给受益人
    // 3.如果募集资金少于目标金额，必须等所有用户将资金提走才可以关闭 关闭之后不会将钱转给受益人
    function close() public returns(bool){   
        require(validable,"Crowdfunding has been closed");
        require(msg.sender == beneficiary,"invalid address");
        if(block.timestamp <= deadline){
            return false;
        }

        if(fundingAmount < fundingGoal && fundingAmount > 0){
           return false;
        }
        validable = false;
        // 检查
        if(fundingAmount >= fundingGoal){
            uint256 amount = fundingAmount;
            // 修改检查条件
            fundingAmount = 0;
            // 执行操作
            payable (beneficiary).transfer(amount);
        }
        return true;
    }

    function withdraw() public returns(bool){
        require(block.timestamp > deadline,"invalid withdraw time");
        require(validable,"Crowdfunding has been closed");
        require(fundingAmount < fundingGoal && fundingAmount>0,"fundingGoal has been finished");

        uint256 index = getFundersIndex(msg.sender);
        if(index == funders.length){
            return false;
        }
        fundingAmount -= funders[index].amount;
        payable (msg.sender).transfer(funders[index].amount);
        return true;
    }

    function fundersLength() public view returns(uint256){
        return funders.length;
    }

    function f(uint x) public view returns (uint256 r) {
        assembly {
            r := sload(x)
        }
    }

}

contract DelegateCrowdfunding{
    struct Funder{
        address funder;
        uint256 amount;
    }

    address public immutable beneficiary;
    uint256 public immutable fundingGoal;
     
    uint256 public fundingAmount;
    Funder[] public funders;

    bool public validable = true;
    uint256 public deadline = block.timestamp + 30 seconds;

    constructor(address beneficiary_,uint256 fundingGoal_){
        beneficiary = beneficiary_;
        fundingGoal = fundingGoal_;
    }

    function getFundersIndex(address _delegateAddr,address _addr) public returns(uint256 index_){
        bytes memory sign = abi.encodeWithSignature("getFundersIndex(address)",_addr);
        (bool success,bytes memory data)= _delegateAddr.delegatecall(sign);
        require(success,"call getFundersIndex error ");
        index_ =  abi.decode(data,(uint256));
    }

    function contribution(address _delegateAddr) public payable {
        bytes memory sign = abi.encodeWithSignature("contribution()");
        (bool success,)= _delegateAddr.delegatecall(sign);
        require(success,"call contribution error");
    }

    function close(address _delegateAddr) public returns(bool){   
        bytes memory sign = abi.encodeWithSignature("close()");
        (bool success,bytes memory data) = _delegateAddr.delegatecall(sign);
        require(success,"call close error");
        return abi.decode(data,(bool));
    }

    function withdraw(address _delegateAddr) public returns(bool){
        bytes memory sign = abi.encodeWithSignature("withdraw()");
        (bool success,bytes  memory data) = _delegateAddr.delegatecall(sign);
        require(success,"call withdraw error");
        return abi.decode(data,(bool));
    }

    function fundersLength(address _delegateAddr) public  returns(uint256){
        bytes memory sign = abi.encodeWithSignature("fundersLength()");
        (bool success,bytes  memory data) = _delegateAddr.delegatecall(sign);
        require(success,"call fundersLength error");
        return abi.decode(data,(uint256));
    }

    function f(uint x) public view returns (uint256 r) {
        assembly {
            r := sload(x)
        }
    }

}


contract Proxy{
    address[] public CrowdfundingList;

    function getBytecode(address beneficiary_,uint256 fundingGoal_) public pure returns (bytes memory) {
        bytes memory bytecode = type(DelegateCrowdfunding).creationCode;

        return abi.encodePacked(bytecode, abi.encode(beneficiary_, fundingGoal_));
    }

    function deploy(bytes memory bytecode, uint256 _salt)
        external
        returns (address){
        address addr;
        require(bytecode.length != 0,"bytecode is zero");
        assembly{
            addr := create2(0,add(bytecode,0x20),mload(bytecode),_salt)
        }
        
        CrowdfundingList.push(addr);

        return addr;
    }
}