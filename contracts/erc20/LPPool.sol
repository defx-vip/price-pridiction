// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import "../interface/IDefxERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";


contract LPPool is Ownable {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    struct UserInfo {
        uint256 amount; // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt.
        uint256 rewardAmount; //
    }

    struct PoolInfo {
        IERC20 lpToken; // Address of LP token contract.
        uint256 allocPoint; // How many allocation points assigned to this pool. TOKENs to distribute per block.
        uint256 lastRewardBlock; // Last block number that TOKENs distribution occurs.
        uint256 accDetTokenPerShare; // Accumulated TOKENs per share, times 1e12. See below.
        string name;//
        uint8 status;
        address token0;
        address token1;
        string token0symbol;
        string token1symbol;
    }

    IERC20 public detToken;
    
    uint256 public detTokenPerBlock;

    uint256 public constant BONUS_MULTIPLIER = 1;

    PoolInfo[] public poolInfo;

    mapping(uint256 => mapping(address => UserInfo)) public userInfo;

    uint256 public totalAllocPoint = 0;
    uint256 public startBlock;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount, uint256 profit);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount, uint256 profit);
    event EmergencyWithdraw(
        address indexed user,
        uint256 indexed pid,
        uint256 amount
    );
    event AddPool(address indexed user, uint256 indexed pid, address _lpToken, string name);

    constructor(
        IERC20 _detToken,
        uint256 _detTokenPerBlock,
        uint256 _startBlock
    ) {
        detToken = _detToken;
        detTokenPerBlock = _detTokenPerBlock;
        startBlock = _startBlock;
    }

    function poolLength() public view returns (uint256) {
        return poolInfo.length;
    }

    function getPool(uint256 _pid)
        public
        view
        returns (
            address lpToken,
            uint256 allocPoint,
            uint256 lastRewardBlock,
            uint256 accDetTokenPerShare,
            string memory name,
            uint8 status,
            address token0,
            address token1,
            string memory token0symbol,
            string memory token1symbol,
            uint256 token0decimals,
            uint256 token1decimals,
            uint256 lpTotalInQuoteToken
        )
    {   
        //避免 Stack too deep, try removing local variables.
        uint256 copyPid = _pid;
        PoolInfo storage pool = poolInfo[copyPid];
        lpToken = address(pool.lpToken);
        allocPoint = pool.allocPoint;
        lastRewardBlock = pool.lastRewardBlock;
        accDetTokenPerShare = pool.accDetTokenPerShare;
        name = pool.name;
        status = pool.status;
        token0 = pool.token0;
        token1 = pool.token1;
        token0symbol = pool.token0symbol;
        token1symbol = pool.token1symbol;
        IDefxERC20 toekn0ERC20 = IDefxERC20(token0);
        IDefxERC20 toekn1ERC20 = IDefxERC20(token1);
        token0decimals = toekn0ERC20.decimals();
        token1decimals = toekn1ERC20.decimals();
        
        (,,lpTotalInQuoteToken) = getPidPrice(copyPid);
    }

    function addPool(
        uint256 _allocPoint,
        IERC20 _lpToken,
        bool _withUpdate,
        string memory _name
    ) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock =
            block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        IDefxERC20 lpToken = IDefxERC20(address(_lpToken));
        IDefxERC20 token0 = IDefxERC20(lpToken.token0());
        IDefxERC20 token1 = IDefxERC20(lpToken.token1());
        poolInfo.push(
            PoolInfo({
                lpToken: _lpToken,
                allocPoint: _allocPoint,
                lastRewardBlock: lastRewardBlock,
                accDetTokenPerShare: 0,
                name: _name,
                status: 1,
                token0: lpToken.token0(),
                token1: lpToken.token1(),
                token0symbol: token0.symbol(),
                token1symbol: token1.symbol()
            })
        );
        emit AddPool(msg.sender, poolInfo.length - 1, address(_lpToken), _name);
    }

    function setPool(
        uint256 _pid,
        uint256 _allocPoint,
        bool _withUpdate,
        uint8 _status
    ) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(
            _allocPoint
        );
        poolInfo[_pid].status = _status;
        poolInfo[_pid].allocPoint = _allocPoint;
    }
    
    // Return reward multiplier over the given _from to _to block.
    function getMultiplier(uint256 _from, uint256 _to)
        public
        pure
        returns (uint256)
    {
        return _to.sub(_from);
    }

    // View function to see pending STARs on frontend.
    function pendingToken(uint256 _pid, address _user)
        external
        view
        returns (uint256)
    {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accTokenPerShare = pool.accDetTokenPerShare;
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier =
                getMultiplier(pool.lastRewardBlock, block.number);
            uint256 starTokenReward =
                multiplier.mul(detTokenPerBlock).mul(pool.allocPoint).div(
                    totalAllocPoint
                );
            accTokenPerShare = accTokenPerShare.add(
                starTokenReward.mul(1e12).div(lpSupply)
            );
        }
        return user.amount.mul(accTokenPerShare).div(1e12).sub(user.rewardDebt);
    }
    
    function getUserInfo(uint256 _pid, address _user)
        public
        view
        returns (uint256 amount, uint256 rewardDebt, uint256 rewardAmount) {
        
        UserInfo storage user = userInfo[_pid][_user];
        amount = user.amount;
        rewardDebt = user.rewardDebt;
        rewardAmount = user.rewardAmount;
    }

    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        uint256 starTokenReward =
            multiplier.mul(detTokenPerBlock).mul(pool.allocPoint).div(
                totalAllocPoint
            );
        pool.accDetTokenPerShare = pool.accDetTokenPerShare.add(
            starTokenReward.mul(1e12).div(lpSupply)
        );
        pool.lastRewardBlock = block.number;
    }

    function deposit(uint256 _pid, uint256 _amount) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        uint256 pending = 0;
        updatePool(_pid);
        if (user.amount > 0) {
            pending =
                user.amount.mul(pool.accDetTokenPerShare).div(1e12).sub(
                    user.rewardDebt
                );
            safeTokenTransfer(msg.sender, pending);
            user.rewardAmount = user.rewardAmount.add(pending);
        }
        pool.lpToken.safeTransferFrom(
            address(msg.sender),
            address(this),
            _amount
        );
        user.amount = user.amount.add(_amount);
        user.rewardDebt = user.amount.mul(pool.accDetTokenPerShare).div(1e12);
        emit Deposit(msg.sender, _pid, _amount, pending);
    }

    function withdraw(uint256 _pid, uint256 _amount) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        updatePool(_pid);
        uint256 pending =
            user.amount.mul(pool.accDetTokenPerShare).div(1e12).sub(
                user.rewardDebt
            );
        safeTokenTransfer(msg.sender, pending);
        user.rewardAmount = user.rewardAmount.add(pending);
        user.amount = user.amount.sub(_amount);
        user.rewardDebt = user.amount.mul(pool.accDetTokenPerShare).div(1e12);
        pool.lpToken.safeTransfer(address(msg.sender), _amount);
        emit Withdraw(msg.sender, _pid, _amount,pending);
    }

    function emergencyWithdraw(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        pool.lpToken.safeTransfer(address(msg.sender), user.amount);
        emit EmergencyWithdraw(msg.sender, _pid, user.amount);
        user.amount = 0;
        user.rewardDebt = 0;
    }

    function safeTokenTransfer(address _to, uint256 _amount) internal {
        require(detToken.balanceOf(address(this)) >= _amount, "balance is not enough!");
        detToken.transfer(_to, _amount);
    }
    
    //1022.5436 1314503.7967
    function getPidPrice(uint256 _pid) public view returns(uint256 tokenAmountMc, uint256 quoteTokenAmountMc, uint256 lpTotalInQuoteToken){
        PoolInfo memory pool = poolInfo[_pid];
        IDefxERC20 lpToken = IDefxERC20(address(pool.lpToken));
        ERC20 token0 = ERC20(lpToken.token0());
        ERC20 token1 = ERC20(lpToken.token1());
        uint256 tokenBalanceLP = token0.balanceOf(address(pool.lpToken));
        uint256 quoteTokenBalanceLP = token1.balanceOf(address(pool.lpToken));
        uint256 lpTokenBalanceMC = pool.lpToken.balanceOf(address(this));
        uint256 lpTotalSupply = pool.lpToken.totalSupply();
        //uint256 s0 = lpTotalSupply.mul(token0.decimals());
        //uint256 s1 =  lpTotalSupply.mul(token1.decimals());
        tokenAmountMc = tokenBalanceLP.mul(lpTokenBalanceMC).div(lpTotalSupply);
        quoteTokenAmountMc = quoteTokenBalanceLP.mul(lpTokenBalanceMC).div(lpTotalSupply);
        lpTotalInQuoteToken = quoteTokenAmountMc.mul(2);
    }
    
}