// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

abstract contract ERC165  {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4) public pure  returns (bool) {
        // return interfaceId == type(IERC165).interfaceId;
        return true;
    }
    // function supportsInterface1(bytes4) public virtual  pure  returns (bool);
}