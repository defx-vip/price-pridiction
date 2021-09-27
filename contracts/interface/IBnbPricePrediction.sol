// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBnbPricePrediction {
    
    function indexRound(uint256 epoch) external view 
        returns(  
            uint256 startBlock,
            uint256 lockBlock,
            uint256 endBlock,
            bool oracleCalled
        );

    function treasuryAmount()external view returns(uint256);

    function claimTreasury()external;
}
