// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//ERC20Capped
interface IAggregator {
    function getCirculationSupply() external view returns (uint256);
}