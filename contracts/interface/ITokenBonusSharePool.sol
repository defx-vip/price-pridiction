// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ITokenBonusSharePool {

    function deposit(address user, address superior, uint256 amount) external payable;

    function airDrop(uint256[] memory nfts, address[] calldata users) external;
}