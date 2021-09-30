// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ITokenBonusSharePool {

    function predictionBet(address user,uint256 amount, uint256 fee) external payable;

    function airDrop(uint256[] memory nfts, address[] calldata users) external;
}