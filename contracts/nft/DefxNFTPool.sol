// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../interface/IDefxNFTFactory.sol";
import "hardhat/console.sol";


contract DefxNFTPool {
    
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    struct UserInfo {
       uint256 totalPoint1;
       uint256 totalPoint2;
       uint256 rewardToken1Debt;
       uint256 rewardToken2Debt;
       uint256 rewardToken1Amount;
       uint256 rewardToken2Amount;
       uint256 nftSize;
    }

    struct NFTInfo {
        address user;
        uint256 point1;
        uint256 point2;
        bool status;
    }

    event NFTReceived(address operator, address from, uint256 tokenId, bytes dat);
    event StakingNFT(address operator, uint256 tokenId, uint256 point1, uint256 point2);
    event UnStakingNFT(address operator, uint256 tokenId, uint256 point1, uint256 point2);
    event Harvest(address operator, uint256 token1Amount, uint256 token2Amount);

    uint256 public totalAllocPoint1 = 0;
    uint256 public totalAllocPoint2 = 0;
    uint256 public startBlock;
    uint256 public detToken1PerBlock;
    uint256 public detToken2PerBlock;
    uint256 public accDetToken1PerShare; //Accumulated TOKENs per share, times 1e12. See below.
    uint256 public accDetToken2PerShare; //Accumulated TOKENs per share, times 1e12. See below.
    uint256 public lastRewardBlock;
    address public token1; //DFT
    address public token2;//DCoin
    address public nftFactory;
    mapping(address => UserInfo) public userInfos;
    mapping(uint256 => NFTInfo) public nftInfos;

    constructor(
        uint256 _startBlock, uint256 _detToken1PerBlock, uint256 _detToken2PerBlock,
        address _token1, address _token2, address _nftFactory) {
        startBlock = _startBlock;
        detToken1PerBlock = _detToken1PerBlock;
        detToken2PerBlock = _detToken2PerBlock;
        token1 = _token1;
        token2 = _token2;
        nftFactory = _nftFactory;
    }
    
    // Return reward multiplier over the given _from to _to block.
    function getMultiplier(uint256 _from, uint256 _to)
        public
        pure
        returns (uint256)
    {
        return _to.sub(_from);
    }

    function updatePool() public {
        if(block.number < lastRewardBlock) {
            return;
        }
        uint256 multiplier = getMultiplier(lastRewardBlock, block.number);
        if(totalAllocPoint1 > 0) {
            uint256 startToken1Reward = detToken1PerBlock.mul(multiplier);
            accDetToken1PerShare = accDetToken1PerShare.add(startToken1Reward.mul(1e12).div(totalAllocPoint1));
        }

        if(totalAllocPoint2 > 0) {
            uint256 startToken2Reward = detToken2PerBlock.mul(multiplier);
            accDetToken2PerShare = accDetToken2PerShare.add(startToken2Reward.mul(1e12).div(totalAllocPoint2));
        }
        lastRewardBlock = block.number;
    }

    function pendingToken(address _user) external view returns(uint256 pendingToken1, uint256 pendingToken2)  {
        uint256 multiplier = getMultiplier(lastRewardBlock, block.number);
        uint256 startToken1Reward = detToken1PerBlock.mul(multiplier);
        uint256 startToken2Reward = detToken2PerBlock.mul(multiplier);
        uint256 _accDetToken1PerShare = 0;
         uint256 _accDetToken2PerShare = 0;
        if(totalAllocPoint1 > 0) {
             _accDetToken1PerShare = accDetToken1PerShare.add(startToken1Reward.mul(1e12).div(totalAllocPoint1));
        }
        if(totalAllocPoint2 > 0) {
             _accDetToken2PerShare = accDetToken2PerShare.add(startToken2Reward.mul(1e12).div(totalAllocPoint2));
        }
        UserInfo memory userInfo = userInfos[_user];
        pendingToken1 = userInfo.totalPoint1.mul(_accDetToken1PerShare).div(1e12).sub(userInfo.rewardToken1Debt);
        pendingToken2 = userInfo.totalPoint2.mul(_accDetToken2PerShare).div(1e12).sub(userInfo.rewardToken2Debt);
    }

    function staking(uint256 tokenId) external {
        require(block.number >= startBlock, "DefxNFTPool: Have not started");
        IDefxNFTFactory defxNFTFactory = IDefxNFTFactory(nftFactory);
        require(msg.sender == defxNFTFactory.ownerOf(tokenId), "DefxNFTPool: caller is not owner");
        (,uint256 quality,,) =  defxNFTFactory.getNFT(tokenId);
        defxNFTFactory.safeTransferFrom(msg.sender, nftFactory, tokenId);
        updatePool();

        UserInfo storage userInfo = userInfos[msg.sender];
        uint256 pendingToken1 = 0;
        uint256 pendingToken2 = 0;
        if(userInfo.totalPoint1 > 0) {
            pendingToken1 = userInfo.totalPoint1.mul(accDetToken1PerShare).div(1e12).sub(userInfo.rewardToken1Debt);
            IERC20(token1).transfer( msg.sender, pendingToken1);
            userInfo.rewardToken1Amount = userInfo.rewardToken1Amount.add(pendingToken1);
            
        }
        if(userInfo.totalPoint2 > 0) {
            pendingToken2 = userInfo.totalPoint2.mul(accDetToken2PerShare).div(1e12).sub(userInfo.rewardToken2Debt);
            IERC20(token2).transfer( msg.sender, pendingToken2);
            userInfo.rewardToken2Amount = userInfo.rewardToken2Amount.add(pendingToken2);
        }
        NFTInfo storage nftInfo = nftInfos[tokenId];
        (uint256 token1Point, uint256 token2Point) = getPoint(quality);
        nftInfo.point1 = token1Point;
        nftInfo.point2 = token2Point;
        nftInfo.user = msg.sender;
        nftInfo.status = true;
       
        totalAllocPoint1 = totalAllocPoint1.add(token1Point);
        totalAllocPoint2 = totalAllocPoint2.add(token2Point);
        userInfo.totalPoint1 = userInfo.totalPoint1.add(token1Point);
        userInfo.totalPoint2 = userInfo.totalPoint2.add(token2Point);
        userInfo.rewardToken1Debt = userInfo.totalPoint1.mul(accDetToken1PerShare).div(1e12);
        userInfo.rewardToken2Debt = userInfo.totalPoint2.mul(accDetToken2PerShare).div(1e12);
        userInfo.nftSize = userInfo.nftSize.add(1);
      
        //console.log("blockNumber = %s", block.number);
        emit StakingNFT(msg.sender, tokenId, token1Point, token2Point);
    }

    function getPoint(uint256 quality) public pure returns(uint256 token1Point, uint256 token2Point) {
        if(quality <= 9) {
            token1Point = 0;
            token2Point = quality.mul(1).add(1);
        } else {
            token1Point = quality.mul(1).add(1);
            token2Point = quality.mul(1).add(1);
        }
    }

    function unstaking(uint256 _tokenId) public {
        NFTInfo storage nftInfo = nftInfos[_tokenId];
        require(nftInfos[_tokenId].user == msg.sender && nftInfo.status, "DefxNFTPool: not your nft or status is error");
         IDefxNFTFactory defxNFTFactory = IDefxNFTFactory(nftFactory);
        defxNFTFactory.safeTransferFrom(nftFactory, msg.sender, _tokenId);
        updatePool();
        UserInfo storage userInfo = userInfos[msg.sender];
        uint256 pendingToken1 = 0;
        uint256 pendingToken2 = 0;
        if(userInfo.totalPoint1 > 0) {
            pendingToken1 = userInfo.totalPoint1.mul(accDetToken1PerShare).div(1e12).sub(userInfo.rewardToken1Debt);
            IERC20(token1).transfer( msg.sender, pendingToken1);
            userInfo.rewardToken1Amount = userInfo.rewardToken1Amount.add(pendingToken1);
        }
        if(userInfo.totalPoint2 > 0) {
            pendingToken2 = userInfo.totalPoint2.mul(accDetToken2PerShare).div(1e12).sub(userInfo.rewardToken2Debt);
            IERC20(token2).transfer(msg.sender, pendingToken2);
            userInfo.rewardToken2Amount = userInfo.rewardToken2Amount.add(pendingToken2);
        }
        nftInfo.status = false;
        totalAllocPoint1 = totalAllocPoint1.sub(nftInfo.point1);
        totalAllocPoint2 = totalAllocPoint2.sub(nftInfo.point2);
        userInfo.totalPoint1 = userInfo.totalPoint1.sub(nftInfo.point1);
        userInfo.totalPoint2 = userInfo.totalPoint2.sub(nftInfo.point2);
        userInfo.rewardToken1Debt = userInfo.totalPoint1.mul(accDetToken1PerShare).div(1e12);
        userInfo.rewardToken2Debt = userInfo.totalPoint2.mul(accDetToken2PerShare).div(1e12);
        userInfo.nftSize = userInfo.nftSize.sub(1);
        emit UnStakingNFT(msg.sender, _tokenId, nftInfo.point1, nftInfo.point2);
    }

     function harvest() public {
        updatePool();
        UserInfo storage userInfo = userInfos[msg.sender];
        uint256 pendingToken1 = 0;
        uint256 pendingToken2 = 0;
        if(userInfo.totalPoint1 > 0) {
            pendingToken1 = userInfo.totalPoint1.mul(accDetToken1PerShare).div(1e12).sub(userInfo.rewardToken1Debt);
            IERC20(token1).transfer( msg.sender, pendingToken1);
            userInfo.rewardToken1Amount = userInfo.rewardToken1Amount.add(pendingToken1);
        }
        //console.log("totalPoint2 %s, accDetToken2PerShare %s  totalAllocPoint2 %s ", userInfo.totalPoint2, accDetToken2PerShare, totalAllocPoint2);
        if(userInfo.totalPoint2 > 0) {
            pendingToken2 = userInfo.totalPoint2.mul(accDetToken2PerShare).div(1e12).sub(userInfo.rewardToken2Debt);
            IERC20(token2).transfer(msg.sender, pendingToken2);
            userInfo.rewardToken2Amount = userInfo.rewardToken2Amount.add(pendingToken2);
        }
        userInfo.rewardToken1Debt = userInfo.totalPoint1.mul(accDetToken1PerShare).div(1e12);
        userInfo.rewardToken2Debt = userInfo.totalPoint2.mul(accDetToken2PerShare).div(1e12);
        emit Harvest(msg.sender, pendingToken1, pendingToken2);
    }

    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory _data) public returns (bytes4) {
        //success
        emit NFTReceived(operator, from, tokenId, _data);
        return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
    }

}