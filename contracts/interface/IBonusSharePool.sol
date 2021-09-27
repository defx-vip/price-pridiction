// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBonusSharePool {

    function deposit(address user) external payable;

    function airDrop(uint256[] memory nfts, address[] calldata users) external;
}