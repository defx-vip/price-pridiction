// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../erc721/DefxNFTFactory.sol";

contract MockDefxNFTFactory is DefxNFTFactory{
   
   address public nftOwner; 

    function setNftOwner(address _nftOwner) external {
        nftOwner = _nftOwner;
    }

    function ownerOf(uint256 tokenId) override external view   returns (address) {
      return  nftOwner;
    }

}