// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import '@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol';
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import '@openzeppelin/contracts/access/Ownable.sol';
import './DefxNFT.sol';
contract MysteryBox is Initializable,Ownable, ReentrancyGuard, ERC721Pausable{
    
    struct BoxFactory {
        uint256 id;
        string name;
        DefxNFT nft;
        uint256 limit; //0 unlimit
        uint256 minted;
        address currency;
        uint256 price;
        string resPrefix; // default res prefix
        address author;
        uint256 createdTime;
    }

    constructor() ERC721('DFT NFT', 'DFT'){
    }



}