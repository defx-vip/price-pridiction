// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0; 
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";
contract PricePredictionReward is ReentrancyGuard, Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    struct Pool {
        uint256 allocPoint;
    }

    struct UserInfo {
        uint256 rewardAmount; //
        uint256 storageReward;
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

    constructor(uint256 _startBlock, uint256 _detTokenPerBlock, address _token) {
        startBlock = _startBlock;
        token = IERC20(_token);
        detTokenPerBlock = _detTokenPerBlock;
    }
    
    mapping(uint256 => mapping(uint256 => PoolDayInfo)) public poolDayInfos; // day => poolId => PoolDayInfo
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    mapping(uint256 => mapping(uint256 => mapping(address => UserDayInfo))) public userDayInfo; //day =>poolid => address >userDayInfo

    function addPool(uint256 allocPoint) public onlyOwner{
       uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock; 
       totalAllocPoint = totalAllocPoint.add(allocPoint);
        pools.push (Pool(
        {
            allocPoint: allocPoint
        }
        ));
        uint256 day = block.timestamp.div(1 days).mul(1 days);
        PoolDayInfo storage dayInfo = poolDayInfos[day][pools.length -1];
        dayInfo.lastRewardBlock = lastRewardBlock;
    }

    function updatePoolInfo(uint256 _pid ,uint256 allocPoint) public onlyOwner{ 
        Pool storage pool = pools[_pid];
        totalAllocPoint = totalAllocPoint.add(allocPoint).sub(pool.allocPoint);
        pool.allocPoint = allocPoint;
    }

    function harvest(uint256 _pid) external nonReentrant{
        uint256 day = block.timestamp.div(1 days).mul(1 days);
        UserInfo storage user = userInfo[_pid][msg.sender];
        PoolDayInfo storage dayInfo = poolDayInfos[day][_pid];
        UserDayInfo storage  _userDayInfo = userDayInfo[day][_pid][msg.sender];
        updatePool(_pid, day);
        uint256 pending = completeDay2(_pid, day, msg.sender);
        _userDayInfo.rewardAmount = _userDayInfo.rewardAmount.add(pending);
        if(user.lastDay != day ) {
            updatePool(_pid, user.lastDay);
            uint256 oldPending = completeDay2(_pid, user.lastDay, msg.sender);
            pending = pending.add(oldPending);
            user.lastDay = day;
        }
        pending = user.storageReward.add(pending);
        token.safeTransfer(msg.sender, pending);
        user.storageReward = 0;
        user.rewardAmount = user.rewardAmount.add(pending);
        _userDayInfo.rewardDebt = _userDayInfo.amount.mul(dayInfo.accDetTokenPerShare).div(1e12);

    }

    function deposit(uint256 _pid, address userAddress, uint256 amount) public nonReentrant{
        UserInfo storage user = userInfo[_pid][userAddress];
        uint256 day = block.timestamp.div(1 days).mul(1 days);
        PoolDayInfo storage dayInfo = poolDayInfos[day][_pid];
        UserDayInfo storage  _userDayInfo = userDayInfo[day][_pid][userAddress];
        uint256 pending = 0;
        updatePool(_pid, day);
        if(user.lastDay != day ) {
            updatePool(_pid, user.lastDay);
            uint256 oldPending = completeDay2(_pid, user.lastDay, userAddress);
            user.storageReward = user.storageReward.add(oldPending);
            pending = pending.add(oldPending);
            user.lastDay = day;
        }
        console.log(" _userDayInfo amount = %s ", _userDayInfo.amount);
        if (_userDayInfo.amount > 0) {
            pending = completeDay2(_pid, day, userAddress);
            console.log(" _userDayInfo amount pending = %s ",pending);
            user.storageReward = user.storageReward.add(pending);
            _userDayInfo.rewardAmount = _userDayInfo.rewardAmount.add(pending);
        }
        _userDayInfo.amount = _userDayInfo.amount.add(amount);
        user.amount = user.amount.add(amount);
        dayInfo.totalAmount = dayInfo.totalAmount.add(amount);
        _userDayInfo.rewardDebt = _userDayInfo.amount.mul(dayInfo.accDetTokenPerShare).div(1e12);
    }

    function completeDay(uint256 _pid, uint256 day, address userAddress) public view returns(uint256){
        PoolDayInfo memory dayInfo = poolDayInfos[day][_pid];
        UserDayInfo memory  _userDayInfo = userDayInfo[day][_pid][userAddress];
        Pool memory pool = pools[_pid];
        uint256 accTokenPerShare = dayInfo.accDetTokenPerShare;
        uint256 lpSupply = dayInfo.totalAmount;
        uint256 pending = 0;
        if(day == 0) {
            return pending;
        }
        uint256 endTime =  block.timestamp;
        if(endTime > day.add(1 days)) {
            endTime = day.add(1 days);
        }
        if (_userDayInfo.amount > 0 && dayInfo.lastRewardBlock < endTime) {
            uint256 multiplier =
                getMultiplier(dayInfo.lastRewardBlock, endTime);
             console.log(" completeDay multiplier = %s ",multiplier);
            uint256 starTokenReward =
                multiplier.mul(detTokenPerBlock).mul(pool.allocPoint).div(
                    totalAllocPoint
                );
            accTokenPerShare = accTokenPerShare.add(
                starTokenReward.mul(1e12).div(lpSupply)
            );

            pending  = _userDayInfo.amount.mul(accTokenPerShare).div(1e12).sub(_userDayInfo.rewardDebt);
        }
        return pending;
    }

     function completeDay2(uint256 _pid, uint256 day, address userAddress) public view returns(uint256){
        PoolDayInfo memory dayInfo = poolDayInfos[day][_pid];
        UserDayInfo memory  _userDayInfo = userDayInfo[day][_pid][userAddress];
        uint256 accTokenPerShare = dayInfo.accDetTokenPerShare;
        uint256 pending = 0;
        if(day == 0) {
            return pending;
        }
        if (_userDayInfo.amount > 0) {
            pending  = _userDayInfo.amount.mul(accTokenPerShare).div(1e12).sub(_userDayInfo.rewardDebt);
        }
        return pending;
    }

    // View function to see pending STARs on frontend.
    function pendingToken(uint256 _pid, address _user)
        public
        view
        returns (uint256)
    {   
        uint256 day = block.timestamp.div(1 days).mul( 1 days);
        UserInfo memory user = userInfo[_pid][_user];
        uint256 pending = completeDay(_pid, day, _user);
        if(user.lastDay != day ) {
         uint256  oldPending = completeDay(_pid, user.lastDay, _user);
         pending = pending.add(oldPending);
        }
        return user.storageReward.add(pending);
    }

    function updatePool(uint256 index, uint256 day) public {
        Pool memory pool = pools[index];
        uint256 endTime =  block.timestamp;
        if(endTime > day.add(1 days)) {
            endTime = day.add(1 days);
        }
        PoolDayInfo storage dayInfo = poolDayInfos[day][index];
        if(dayInfo.totalAmount > 0 && dayInfo.lastRewardBlock < endTime) {
           uint256 multiplier = getMultiplier(dayInfo.lastRewardBlock, endTime);
           uint256 starTokenReward =
            multiplier.mul(detTokenPerBlock).mul(pool.allocPoint).div(
                totalAllocPoint
            );
            dayInfo.accDetTokenPerShare = dayInfo.accDetTokenPerShare.add(
                starTokenReward.mul(1e12).div(dayInfo.totalAmount)
            );
        }
        dayInfo.lastRewardBlock = endTime;
        
    }

    function getUserInfo(uint256 index, uint256 day, address _user) public view returns(uint256 dayAmount, uint256 amount, uint256 dayReward, uint256 reward){

        uint256 pending = completeDay(index, day, _user);
        UserInfo memory user = userInfo[index][msg.sender];
        UserDayInfo memory  _userDayInfo = userDayInfo[day][index][msg.sender];
        dayAmount = _userDayInfo.amount;
        amount = user.amount;
        dayReward = _userDayInfo.rewardAmount.add(pending);
        reward = user.rewardAmount.add(pendingToken(index, _user));
    }

    function massUpdatePools() public {
        uint256 length = pools.length;
        uint256 day = block.timestamp.div(1 days).mul( 1 days);
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid, day);
        }
    }

    function getMultiplier(uint256 _from, uint256 _to)
        public
        pure
        returns (uint256)
    {
        return _to.sub(_from);
    }


}