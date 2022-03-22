// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../interface/IDefxERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../interface/IDefxOptionPool.sol";
import "../interface/IDefxERC20.sol";
import "hardhat/console.sol";
contract OptionPool is Ownable {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    struct UserInfo {
        uint256 amount; // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt.
        uint256 rewardAmount; //
        uint256 nftSize;
    }

   struct NFTInfo {
        address user;
        uint256 amount;
        bool status;
    }
    
    struct PoolInfo {
        address lpToken; // Address of LP token contract.
        uint256 allocPoint; // How many allocation points assigned to this pool. TOKENs to distribute per block.
        uint256 lastRewardBlock; // Last block number that TOKENs distribution occurs.
        uint256 accDetTokenPerShare; // Accumulated TOKENs per share, times 1e12. See below.
        string name;//
        uint8 status;
        address token0;
        string token0symbol;
        uint256 decimals;
        uint256 totalAmount;
    }

    address public detToken;
    uint256 public detTokenPerBlock;
    PoolInfo[] public poolInfo;
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    uint256 public totalAllocPoint = 0;
    uint256 public startBlock;
    mapping(uint256 => NFTInfo) public nftInfo;

    event Staking(address indexed user, uint256 indexed pid, uint256 indexed tokenId,uint256 amount, uint256 profit);
    event UnStaking(address indexed user, uint256 indexed pid, uint256 indexed tokenId,uint256 amount, uint256 profit);
    event Harvest(address operator, uint256 pid, uint256 tokenAmount);
    event NFTReceived(address operator, address from, uint256 tokenId, bytes dat);
    event AddPool(address indexed user, uint256 indexed pid, address _lpToken, string name);

    constructor(
        address _detToken,
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
            string memory token0symbol,
            uint256 decimals,
            uint256 totalAmount
        )
    {   
        PoolInfo memory pool = poolInfo[_pid];
        lpToken = address(pool.lpToken);
        allocPoint = pool.allocPoint;
        lastRewardBlock = pool.lastRewardBlock;
        accDetTokenPerShare = pool.accDetTokenPerShare;
        name = pool.name;
        status = pool.status;
        token0 = pool.token0;
        token0symbol = pool.token0symbol;
        decimals = pool.decimals;
        totalAmount = pool.totalAmount;
    }
    
    function addPool(
        uint256 _allocPoint,
        address _lpToken,
        bool _withUpdate,
        string memory _name
    ) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock =
            block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        IDEFXPool defxPool = IDEFXPool(_lpToken);
        console.log("_lpToken = %s", _lpToken);
        IDefxERC20 token0 = IDefxERC20( address(defxPool.token()));
        poolInfo.push(
            PoolInfo({
                lpToken: _lpToken,
                allocPoint: _allocPoint,
                lastRewardBlock: lastRewardBlock,
                accDetTokenPerShare: 0,
                name: _name,
                status: 1,
                token0: address(defxPool.token()),
                token0symbol: token0.symbol(),
                decimals: token0.decimals(),
                totalAmount: 0
            })
        );
        emit AddPool(msg.sender, poolInfo.length - 1, _lpToken, _name);
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
        public
        view
        returns (uint256)
    {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accTokenPerShare = pool.accDetTokenPerShare;
        uint256 lpSupply = pool.totalAmount;
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
        returns (uint256 amount, uint256 rewardDebt, uint256 rewardAmount, uint256 nftSize, uint256 pending) {
        
        UserInfo storage user = userInfo[_pid][_user];
        amount = user.amount;
        rewardDebt = user.rewardDebt;
        rewardAmount = user.rewardAmount;
        nftSize = user.nftSize;
        pending = pendingToken(_pid, _user);
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
        uint256 lpSupply = pool.totalAmount;
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

    function staking(uint256 _pid, uint256 _tokenId) public {
        PoolInfo storage pool = poolInfo[_pid];
        IDEFXPool defxPool = IDEFXPool(pool.lpToken);
        require(defxPool.ownerOf(_tokenId) == msg.sender, "OptionPool: caller is not owner");
        (IDEFXPool.TrancheState state,,uint256 _amount,,) =  defxPool.tranches(_tokenId);
        require(state == IDEFXPool.TrancheState.Open);
        UserInfo storage user = userInfo[_pid][msg.sender];
        NFTInfo storage nft = nftInfo[_tokenId];
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
        defxPool.transferFrom(msg.sender, address(this), _tokenId);
        
        pool.totalAmount = pool.totalAmount.add(_amount);
        user.amount = user.amount.add(_amount);
        user.rewardDebt = user.amount.mul(pool.accDetTokenPerShare).div(1e12);
        nft.amount = _amount;
        nft.user = msg.sender;
        nft.status = true;
        emit Staking(msg.sender, _pid, _tokenId, _amount, pending);
    }

    function unstaking(uint256 _pid, uint256 _tokenId) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        NFTInfo storage nft = nftInfo[_tokenId];
        require(nft.user >= msg.sender, "OptionPool: not your nft");
        updatePool(_pid);
        uint256 pending =
            user.amount.mul(pool.accDetTokenPerShare).div(1e12).sub(
                user.rewardDebt
            );
        safeTokenTransfer(msg.sender, pending);
        user.rewardAmount = user.rewardAmount.add(pending);
        IDEFXPool defxPool = IDEFXPool(pool.lpToken);
        defxPool.transferFrom(address(this), msg.sender, _tokenId);
        pool.totalAmount = pool.totalAmount.sub(nft.amount);
        user.amount = user.amount.sub(nft.amount);
        user.rewardDebt = user.amount.mul(pool.accDetTokenPerShare).div(1e12);
        emit UnStaking(msg.sender, _pid, _tokenId, nft.amount, pending);
    }

    function harvest(uint256 _pid) public { 
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        uint256 pending =
            user.amount.mul(pool.accDetTokenPerShare).div(1e12).sub(
                user.rewardDebt
            );
        safeTokenTransfer(msg.sender, pending);
        user.rewardAmount = user.rewardAmount.add(pending);
        user.rewardDebt = user.amount.mul(pool.accDetTokenPerShare).div(1e12);
        emit Harvest(msg.sender, _pid, pending);
    }

    function safeTokenTransfer(address _to, uint256 _amount) internal {
        require(IERC20(detToken).balanceOf(address(this)) >= _amount, "balance is not enough!");
        IERC20(detToken).transfer(_to, _amount);
    }

     function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data) public returns (bytes4) {
        //only receive the _nft staff
        if(address(this) != operator) {
            //invalid from nft
            return 0;
        }
        //success
        emit NFTReceived(operator, from, tokenId, data);
        return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
    }
}