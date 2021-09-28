// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IUserRelation {

    function bindUser(address user, address superior) external view returns(bool);

    function getUserInfo(address user) external view returns(address superior, uint8 role, bool isBind);

    function getSuperior(address user) external view returns(address superior);
}