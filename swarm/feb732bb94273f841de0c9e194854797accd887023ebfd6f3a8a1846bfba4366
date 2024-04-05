// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC721.sol";
import "./ERC721Enumerable.sol";
import "./ERC721Burnable.sol";
import "./ERC721Pausable.sol";
import "./Ownable.sol";
// import "./SafeMath.sol";
// import "@openzeppelin/contracts/utils/Counters.sol";
contract CreditTiger is  ERC721Enumerable,Ownable, ERC721Burnable, ERC721Pausable {
    // event Log(string msg);
    //Test
    constructor(address initialOwner) ERC721("Credit-Tiger", "CTT") Ownable(initialOwner) {

    }  
    
    function _increaseBalance(address account, uint128 amount) internal virtual override(ERC721Enumerable,ERC721) {
        super._increaseBalance(account, amount);
    }

    function _update(address to, uint256 tokenId, address auth) internal virtual override(ERC721Enumerable,ERC721,ERC721Pausable) returns (address) {
        // super._update(to,);
    }
 
     function test1() public  override(ERC721Enumerable,ERC721,ERC721Pausable)  {
        emit Log("CreditTiger.test1");
        super.test1();
    }
    

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721Enumerable,ERC721) returns (bool) {
        return super.supportsInterface(interfaceId);
    }



}