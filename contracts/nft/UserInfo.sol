// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../interface/IDefxNFTFactory.sol";
contract UserInfo { 
    
    struct User {
        uint256 nftId;
        string nickname;
    }

    address public nftFactory;
    //Mapping that stores user information
    mapping(address => User) public data;

    constructor(address _nftFactory) {
        nftFactory = _nftFactory;
    }

    function setUserNFTId(uint256 _nftId) public {
       require(_nftId > 0 && IDefxNFTFactory(nftFactory).ownerOf(_nftId) == msg.sender, "nftId error");
       data[msg.sender].nftId = _nftId;
    }

    function setUserNickname(string calldata _nickname) public {
       require( bytes(_nickname).length < 10, "_nickname error");
       data[msg.sender].nickname = _nickname;
    }

}