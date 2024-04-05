// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract Oracle {
    struct Request {
        bytes data;
        function(uint256) external callback;
    }
    Request[] private requests;
    event NewRequest(uint256);

    function query(bytes memory data, function(uint256) external callback)
        external
    {
        requests.push(Request(data, callback));
        emit NewRequest(requests.length - 1);
    }

    function reply(uint256 requestID, uint256 response) public {
        // 这里检查回复来自可信来源
        requests[requestID].callback(response);
    }
}

contract OracleUser {
    Oracle private constant ORACLE_CONST =
        Oracle(address(0x00000000219ab540356cBB839Cbe05303d7705Fa)); // known contract
    uint256 private exchangeRate;

    function buySomething() public {
        // ORACLE_CONST.query("USD", this.oracleResponse);
    }

    function oracleResponse(uint256 response) public {
        require(
            msg.sender == address(ORACLE_CONST),
            "Only oracle can call this."
        );
        exchangeRate = response;
    }
}