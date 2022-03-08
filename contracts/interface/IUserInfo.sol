// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0; 

interface IUserInfo {

    function getUserInfo(address user) external view returns(uint256 nftId, string memory nickname);

    function nftFactory() external view returns(address nftFactoryAddress);
}