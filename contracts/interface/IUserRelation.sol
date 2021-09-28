// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IUserRelation {

    function bindUser(address user, address superior) external returns(bool);

    function getUserInfo(address user) external view returns(address superior, bool isBroker, bool isBind, uint8 rewardRate);

    function getSuperior(address user) external view returns(address superior);

    function getDftTeam() external view returns(address);
}