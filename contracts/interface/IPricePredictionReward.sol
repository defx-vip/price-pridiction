// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0; 

interface IPricePredictionReward {
    function deposit(uint256 _pid, address userAddress, uint256 amount) external;
}