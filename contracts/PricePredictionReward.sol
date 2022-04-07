// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0; 
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
contract PricePredictionReward is ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    struct Pool {
        uint256 allocPoint;
    }

    struct UserInfo {
        uint256 rewardAmount; //
        uint256 pendingReward;
        uint256 amount; 
        uint256 lastDay;
    }
    
    struct PoolDayInfo {
        uint256 totalAmount;
        uint256 accDetTokenPerShare;
        uint256 lastRewardBlock; // Last block number that TOKENs distribution occurs.
    }

    struct UserDayInfo {
        uint256 amount; // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt.
        uint256 rewardAmount; //
    }

    uint256 public detTokenPerBlock;
    uint256 public totalAllocPoint = 0;
    uint256 public startBlock;
    Pool[] public pools;
    IERC20 public token;

    constructor(uint256 _startBlock, address _token) {
        startBlock = _startBlock;
        token = IERC20(_token);
    }
    
    mapping(uint256 => mapping(uint256 => PoolDayInfo)) public poolDayInfos; // day => poolId => PoolDayInfo
    mapping(address => UserInfo) public userInfo;
    mapping(uint256 => mapping(address => UserDayInfo)) public userDayInfo;

    function addPool(uint256 allocPoint) public{
        pools.push (Pool(
        {
            allocPoint: allocPoint
        }
        ));
    }

    function updatePoolInfo(uint256 _pid ,uint256 allocPoint) public{ 
        Pool storage pool = pools[_pid];
        pool.allocPoint = allocPoint;
    }

    function harvest(uint256 _pid) external nonReentrant{
        uint256 day = block.timestamp.div(1 days);
        Pool memory pool = pools[_pid];
        UserInfo memory user = userInfo[msg.sender];
        PoolDayInfo memory dayInfo = poolDayInfos[day][_pid];
        UserDayInfo memory  _userDayInfo = userDayInfo[day][msg.sender];
        uint256 accTokenPerShare = dayInfo.accDetTokenPerShare;
        uint256 lpSupply = dayInfo.totalAmount;
        if (block.number > dayInfo.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier =
                getMultiplier(dayInfo.lastRewardBlock, block.timestamp);
            uint256 starTokenReward =
                multiplier.mul(detTokenPerBlock).mul(pool.allocPoint).div(
                    totalAllocPoint
                );
            accTokenPerShare = accTokenPerShare.add(
                starTokenReward.mul(1e12).div(lpSupply)
            );
        }
        updatePool(_pid, day);
        uint256 pending = _userDayInfo.amount.mul(accTokenPerShare).div(1e12).sub(_userDayInfo.rewardDebt);
        _userDayInfo.rewardAmount = _userDayInfo.rewardAmount.add(pending);
        if(user.lastDay != day) {
            pending = pending.add(completeDay(_pid, user.lastDay, msg.sender));
        }
        pending = user.pendingReward.add(pending);

    }

    function deposit(uint256 _pid, address userAddress, uint256 amount)public nonReentrant{
        UserInfo storage user = userInfo[userAddress];
        uint256 day = block.timestamp.div(1 days);
        PoolDayInfo memory dayInfo = poolDayInfos[day][_pid];
        UserDayInfo storage  _userDayInfo = userDayInfo[day][userAddress];
        uint256 pending = 0;
        updatePool(_pid, day);
        if(user.lastDay != day) {
            uint256 oldPending = completeDay(_pid, user.lastDay, userAddress);
            user.pendingReward = user.pendingReward.add(oldPending);
            user.lastDay = day;
        }
        if (_userDayInfo.amount > 0) {
            pending = _userDayInfo.amount.mul(dayInfo.accDetTokenPerShare).div(1e12).sub(_userDayInfo.rewardDebt);
            user.pendingReward = user.pendingReward.add(pending);
            _userDayInfo.rewardAmount = _userDayInfo.rewardAmount.add(pending);
        }
        _userDayInfo.amount = _userDayInfo.amount.add(amount);
        user.amount = user.amount.add(amount);
        _userDayInfo.rewardDebt = _userDayInfo.amount.mul(dayInfo.accDetTokenPerShare).div(1e12);
    }

    function completeDay(uint256 _pid, uint256 day, address userAddress) public view returns(uint256){
        PoolDayInfo memory dayInfo = poolDayInfos[day][_pid];
        UserDayInfo memory  _userDayInfo = userDayInfo[day][userAddress];
         uint256 pending = 0;
        if (_userDayInfo.amount > 0) {
            pending = _userDayInfo.amount.mul(dayInfo.accDetTokenPerShare).div(1e12).sub(_userDayInfo.rewardDebt);
        }
        return pending;
    }

    // View function to see pending STARs on frontend.
    function pendingToken(uint256 _pid, address _user)
        public
        view
        returns (uint256)
    {   
        uint256 day = block.timestamp.div(1 days);
        Pool memory pool = pools[_pid];
        UserInfo memory user = userInfo[_user];
        PoolDayInfo memory dayInfo = poolDayInfos[day][_pid];
        UserDayInfo memory  _userDayInfo = userDayInfo[day][_user];
        uint256 accTokenPerShare = dayInfo.accDetTokenPerShare;
        uint256 lpSupply = dayInfo.totalAmount;
        if (block.number > dayInfo.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier =
                getMultiplier(dayInfo.lastRewardBlock, block.timestamp);
            uint256 starTokenReward =
                multiplier.mul(detTokenPerBlock).mul(pool.allocPoint).div(
                    totalAllocPoint
                );
            accTokenPerShare = accTokenPerShare.add(
                starTokenReward.mul(1e12).div(lpSupply)
            );
        }
        uint256 pending = _userDayInfo.amount.mul(accTokenPerShare).div(1e12).sub(_userDayInfo.rewardDebt);
        if(user.lastDay != day) {
            pending = pending.add(completeDay(_pid, user.lastDay, _user));
        }
        return user.pendingReward.add(pending);
    }

    function updatePool(uint256 index, uint256 day) public {
        Pool memory pool = pools[index];
        uint256 endTime =  block.timestamp;
        if(endTime > day.add(1 days)) {
            endTime = day.add(1 days);
        }
        PoolDayInfo storage dayInfo = poolDayInfos[day][index];
        if(dayInfo.totalAmount > 0) {
           uint256 multiplier = getMultiplier(dayInfo.lastRewardBlock, endTime);
           uint256 starTokenReward =
            multiplier.mul(detTokenPerBlock).mul(pool.allocPoint).div(
                totalAllocPoint
            );
            dayInfo.accDetTokenPerShare = dayInfo.accDetTokenPerShare.add(starTokenReward);
        }
        dayInfo.lastRewardBlock = endTime;
    }

    function getMultiplier(uint256 _from, uint256 _to)
        public
        pure
        returns (uint256)
    {
        return _to.sub(_from);
    }

}