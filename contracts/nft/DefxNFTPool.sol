// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../interface/IDefxNFTFactory.sol";


contract DefxNFTPool {
    
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    struct UserInfo {
       uint256 totalPoint;
       uint256 rewardToken1Debt;
       uint256 rewardToken2Debt;
       uint256 rewardToken1Amount;
       uint256 rewardToken2Amount;
       uint256 nftSize;
    }

    struct NFTInfo {
        address user;
        uint256 point;
        bool status;
    }

    event NFTReceived(address operator, address from, uint256 tokenId, bytes dat);
    event StakingNFT(address operator, uint256 tokenId, uint256 point);
    event UnStakingNFT(address operator, uint256 tokenId, uint256 point);

    uint256 public totalAllocPoint = 0;
    uint256 public startBlock;
    uint256 public detToken1PerBlock;
    uint256 public detToken2PerBlock;
    uint256 public accDetToken1PerShare; //Accumulated TOKENs per share, times 1e12. See below.
    uint256 public accDetToken2PerShare; //Accumulated TOKENs per share, times 1e12. See below.
    uint256 public lastRewardBlock;
    address public token1; //DFT
    address public token2;//DCoin
    address public nftFactory;
    mapping(address => UserInfo) userInfos;
    mapping(uint256 => NFTInfo) nftInfos;


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
        if(totalAllocPoint <= 0) {
            lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = getMultiplier(lastRewardBlock, block.number);
        uint256 startToken1Reward = detToken1PerBlock.mul(multiplier);
        uint256 startToken2Reward = detToken1PerBlock.mul(multiplier);
        accDetToken1PerShare = accDetToken1PerShare.add(startToken1Reward.mul(1e12).div(totalAllocPoint));
        accDetToken2PerShare = accDetToken1PerShare.add(startToken2Reward.mul(1e12).div(totalAllocPoint));
        lastRewardBlock = block.number;
    }

    function pendingToken(address _user) external returns(uint256 pendingToken1, uint256 pendingToken2) {
        uint256 multiplier = getMultiplier(lastRewardBlock, block.number);
        uint256 startToken1Reward = detToken1PerBlock.mul(multiplier);
        uint256 startToken2Reward = detToken1PerBlock.mul(multiplier);
        accDetToken1PerShare = accDetToken1PerShare.add(startToken1Reward.mul(1e12).div(totalAllocPoint));
        accDetToken2PerShare = accDetToken2PerShare.add(startToken2Reward.mul(1e12).div(totalAllocPoint));
        UserInfo memory userInfo = userInfos[_user];
        pendingToken1 = userInfo.totalPoint.mul(accDetToken1PerShare).div(1e12).sub(userInfo.rewardToken1Debt);
        pendingToken2 = userInfo.totalPoint.mul(accDetToken2PerShare).div(1e12).sub(userInfo.rewardToken1Debt);
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
        if(userInfo.totalPoint > 0) {
            pendingToken1 = userInfo.totalPoint.mul(accDetToken1PerShare).div(1e12).sub(userInfo.rewardToken1Debt);
            IERC20(token1).transferFrom(address(this), msg.sender, pendingToken1);
            pendingToken2 = userInfo.totalPoint.mul(accDetToken2PerShare).div(1e12).sub(userInfo.rewardToken2Debt);
            IERC20(token2).transferFrom(address(this), msg.sender, pendingToken2);
            userInfo.rewardToken1Amount = userInfo.rewardToken1Amount.add(pendingToken1);
            userInfo.rewardToken2Amount = userInfo.rewardToken2Amount.add(pendingToken2);
        }
        NFTInfo storage nftInfo = nftInfos[tokenId];
        nftInfo.point = quality;
        nftInfo.user = msg.sender;
        nftInfo.status = true;
        totalAllocPoint = totalAllocPoint.add(quality);
        userInfo.totalPoint = userInfo.totalPoint.add(quality);
        userInfo.rewardToken1Debt = userInfo.totalPoint.mul(accDetToken1PerShare).div(1e12);
        userInfo.rewardToken2Debt = userInfo.totalPoint.mul(accDetToken2PerShare).div(1e12);
        userInfo.nftSize = userInfo.nftSize.add(1);
        emit StakingNFT(msg.sender, tokenId, quality);
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
        if(userInfo.totalPoint > 0) {
            pendingToken1 = userInfo.totalPoint.mul(accDetToken1PerShare).div(1e12).sub(userInfo.rewardToken1Debt);
            IERC20(token1).transferFrom(address(this), msg.sender, pendingToken1);
            pendingToken2 = userInfo.totalPoint.mul(accDetToken2PerShare).div(1e12).sub(userInfo.rewardToken2Debt);
            IERC20(token2).transferFrom(address(this), msg.sender, pendingToken2);
            userInfo.rewardToken1Amount = userInfo.rewardToken1Amount.add(pendingToken1);
            userInfo.rewardToken2Amount = userInfo.rewardToken2Amount.add(pendingToken2);
        }
        nftInfo.status = false;
        totalAllocPoint = totalAllocPoint.sub(nftInfo.point);
        userInfo.totalPoint = userInfo.totalPoint.sub(nftInfo.point);
        userInfo.rewardToken1Debt = userInfo.totalPoint.mul(accDetToken1PerShare).div(1e12);
        userInfo.rewardToken2Debt = userInfo.totalPoint.mul(accDetToken2PerShare).div(1e12);
        userInfo.nftSize = userInfo.nftSize.sub(1);
        emit UnStakingNFT(msg.sender, _tokenId, nftInfo.point);
    }

    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory _data) public returns (bytes4) {
        //success
        emit NFTReceived(operator, from, tokenId, _data);
        return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
    }

}