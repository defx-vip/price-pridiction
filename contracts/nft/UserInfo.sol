// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../interface/IDefxNFTFactory.sol";

contract UserInfo { 
    
    struct User {
        uint256 nftId;
        string nickname;
    }
    event NFTReceived(address operator, address from, uint256 tokenId, bytes dat);
    event UpdateNFT(address user, uint256 tokenId);
    address public nftFactory;
    //Mapping that stores user information
    mapping(address => User) public data;

    constructor(address _nftFactory) {
        nftFactory = _nftFactory;
    }

    function setUserNFTId(uint256 _nftId) public {
       require(_nftId > 0 && IDefxNFTFactory(nftFactory).ownerOf(_nftId) == msg.sender, "nftId error");
         if(data[msg.sender].nftId != 0)
            IDefxNFTFactory(nftFactory).safeTransferFrom(address(this), msg.sender, data[msg.sender].nftId);
        IDefxNFTFactory(nftFactory).safeTransferFrom(msg.sender , address(this), _nftId);
        data[msg.sender].nftId = _nftId;
        emit UpdateNFT(msg.sender, _nftId);
    }

    function setUserNFTNull() public {
        if(data[msg.sender].nftId != 0)
            IDefxNFTFactory(nftFactory).safeTransferFrom(address(this), msg.sender, data[msg.sender].nftId);
        data[msg.sender].nftId = 0;
        emit UpdateNFT(msg.sender, 0);
    }

    function setUserNickname(string calldata _nickname) public {
       require( bytes(_nickname).length < 12, "_nickname error");
       data[msg.sender].nickname = _nickname;
    }

    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory _data) public returns (bytes4) {
        //success
        emit NFTReceived(operator, from, tokenId, _data);
        return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
    }

     function getUserInfo(address user) external view returns(uint256 nftId, string memory nickname) {
         User memory userInfo = data[user];
         nftId = userInfo.nftId;
         nickname = userInfo.nickname;
     }
}