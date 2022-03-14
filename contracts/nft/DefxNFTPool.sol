// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DefxNFTPool {

    struct UserInfo {
       uint256 totalPoint;
       uint256 rewardDebt;
       uint256 rewardAmount;
       uint256 nftSize;
    }

    uint256 public totalAllocPoint = 0;
    uint256 public startBlock;
    uint256 public detToken1PerBlock;
    uint256 public detToken2PerBlock;
    uint256 public accDetTokenPerShare; //Accumulated TOKENs per share, times 1e12. See below.
    uint256 public lastRewardBlock;

    
    function updatePool() external {

    }


}