// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Demo{
    // uint256[] private arr;
    uint256[][] public secArr;

    function getSecArr(uint256 index) public view returns(uint256[] memory){
        return secArr[index];
    } 

    function countLocal1(bytes32 _bts) public pure returns(bytes32 ){
        bytes memory bts = new bytes(_bts.length);
        for(uint256 i = 0 ; i < _bts.length ; i++){
            bts[i] = _bts[i];
        }
        return keccak256(bts);  
    }

    // 0x290decd9548b62a8d60345a988386fc84ba6bc95484008f6362f93160ef3e563
    function countLocal() public returns (bytes32){
        // arr.push(11);
        uint256[] memory arr1 = new uint256[](3);
        arr1[0] = 11;
        arr1[1] = 22;
        arr1[2] = 33;
        secArr.push(arr1);

        uint256[] memory arr2 = new uint256[](4);
        arr2[0] = 44;
        arr2[1] = 55;
        arr2[2] = 66;
        arr2[3] = 77;
        secArr.push(arr2);
        bytes32 arrLocal = bytes32(uint256(0));
        bytes memory bts = new bytes(arrLocal.length);
        for(uint256 i = 0 ; i < arrLocal.length ; i++){
            bts[i] = arrLocal[i];
        }
        return keccak256(bts);      
    }

    function getDateFromLocal(bytes32 data) public view returns(uint256 b){
        assembly {
            // v 是长度是 32 bytes
            b := sload(data)
        }
    } 

    // 0x290decd9548b62a8d60345a988386fc84ba6bc95484008f6362f93160ef3e564
    function add(bytes32 bts) public pure returns(bytes32){
        uint256 temp = uint256(bts);
        return bytes32(temp + 1);
    }


    // 0 , 1 0x510e4e770828ddbf7f7b00ab00a9f6adaf81c0dc9cc85f1f8249c256942d61d9
         //  0x510e4e770828ddbf7f7b00ab00a9f6adaf81c0dc9cc85f1f8249c256942d61da
    // 1 , 1 0x6c13d8c1c5df666ea9ca2a428504a3776c8ca01021c3a1524ca7d765f600979b
         //  0x6c13d8c1c5df666ea9ca2a428504a3776c8ca01021c3a1524ca7d765f600979b
    //keccak256(keccak256(p) + i) + floor(j / floor(256 / 24))
    function getLocal(uint256 i,uint256 j) public pure returns(bytes32){
        bytes32 arrLocal = bytes32(uint256(0));
        bytes memory bts = new bytes(arrLocal.length);
        for(uint256 k = 0 ; k < arrLocal.length ; k++){
            bts[k] = arrLocal[k];
        }

        bytes32 arrLocal1 = bytes32(uint256(keccak256(bts)) +i);
        bytes memory bts1 = new bytes(arrLocal1.length);
        for(uint256 p = 0 ; p < arrLocal1.length ; p++){
            bts1[p] = arrLocal1[p];
        }
        uint256 h = j * 256 / 256;
        return bytes32(uint256(keccak256(bts1)) + h);
    }

    
}