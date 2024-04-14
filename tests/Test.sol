// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
contract DynamicSizeVariable {
    uint256[] public dynamicArray = new uint256[](3);

    // 向动态数组 dynamicArray 中添加元素
    function addElement() public {
        dynamicArray[0] = 43;
        dynamicArray[1] = 25;
        dynamicArray[2] = 32;
    }

    //0x290decd9548b62a8d60345a988386fc84ba6bc95484008f6362f93160ef3e563
    //0x290decd9548b62a8d60345a988386fc84ba6bc95484008f6362f93160ef3e564
    function getlocaltion() public pure returns (bytes32 c) {
        bytes32 bts32 = bytes32(uint256(0));
        bytes memory bts = new bytes(bts32.length);
        //  uint256 num = bts.length;
        for (uint256 i = 0; i < bts32.length; i++) {
            bts[0] = bts32[0];
        }
        bytes32 b = keccak256(bts);
        c = bytes32(uint256(b) + 1);
    }
}
