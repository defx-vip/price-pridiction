// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IDefxNFTFactory {

   function doMint(address author, uint256 resId, uint256 amount) external returns (uint256);

   function safeTransferFrom(address from, address to, uint256 tokenId) external;

   function ownerOf(uint256 tokenId) external view  returns (address);

   function getNFT(uint256 tokenId) external view
        returns (
            uint256 grade,
            uint256 quality,
            uint256 resId,
            address author
        );
}