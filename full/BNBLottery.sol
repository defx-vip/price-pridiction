// File: contracts/interface/IDefxNFTFactory.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IDefxNFTFactory {

   function doMint(address author, uint256 resId, uint256 amount) external returns (uint256);

   function safeTransferFrom(address from, address to, uint256 tokenId) external;

   function ownerOf(uint256 tokenId) external view  returns (address);

   function getNFT(uint256 tokenId) external view
        returns (
            uint256 grade,
            uint256 quality,
            uint256 resId,
            address author
        );
}

// File: contracts/interface/AggregatorV3Interface.sol


pragma solidity ^0.8.0;
/**
 * 预言机

 */
interface AggregatorV3Interface {
    function decimals() external view returns (uint8);

    function description() external view returns (string memory);

    function version() external view returns (uint256);

    // getRoundData and latestRoundData should both raise "No data present"
    // if they do not have data to report, instead of returning unset values
    // which could be misinterpreted as actual reported values.
    function getRoundData(uint80 _roundId)
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );

    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );
}

// File: @openzeppelin/contracts/utils/math/SafeMath.sol



pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// File: @openzeppelin/contracts/utils/Context.sol



pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File: @openzeppelin/contracts/security/Pausable.sol



pragma solidity ^0.8.0;


/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// File: @openzeppelin/contracts/proxy/utils/Initializable.sol



pragma solidity ^0.8.0;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol



pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: contracts/prediction/BNBLottery.sol


pragma solidity ^0.8.0;







contract BNBLottery  is Pausable, Initializable{

    using SafeMath for uint256;

    struct AoLiGei {
        uint256 id;
        uint256 grade;
        uint256 quality;
        uint256 amount;
        uint256 createdTime;
        uint256 blockNum;
        uint256 resId;
        address author;
    }

    //彩票周期
    struct Round {
        uint256 epoch; //index
        uint256 startBlock; //开始区块
        uint256 endBlock; //开奖区块
        uint256 totalPonits;//总积分
        uint256 rewardAmount; //赢家金额
        bool oracleCalled; //是否已经结算
        uint8 roundRewardLevel;
        uint256 winnerNumber;//
        uint256 randomNumber;
    }

    //质押
    struct BetInfo {
        uint256 nftTokenId;
        bool claimed; // 是否需要领取
        uint256 point;//中奖概率分数
        uint256 startPoint;
        uint256 endPoint;
    }

    event StartRound(uint256 indexed epoch, uint256 startBlock, uint256 endBlock, uint256 rewardAmount, uint256 roundRewardLevel);

    event EndRound(uint256 indexed epoch, uint256 blockNumber,  uint256 winnerNumber);

    event Bet(address indexed sender, uint256 indexed currentEpoch, uint256 nftTokenId, uint256 startPoint, uint256 endPoint);

    event Claim(address indexed sender, uint256 indexed currentEpoch, uint256 amount, uint256 nftTokenId, uint point);

    event Pause(uint256 epoch);

    event Unpause(uint256 epoch);

    bool public genesisStartOnce; //是否调用初始化开始方法

    uint256 public currentEpoch; //当前周期角标

    uint256 public intervalBlocks; //100

    uint256 public bufferBlocks; //15 

    address public adminAddress; //管理员地址

    address public operatorAddress; //操作员地址

    uint256 public roundRewardAmount; //奖励金额

    uint8 public roundRewardLevel; //奖励金额等级

    uint256 public minBetAmount; //最小奖励金额

    mapping(uint256 => Round) public rounds; //期权周期mapping, currentEpoch

    mapping(uint256 => mapping(uint256 => BetInfo)) public ledger; //期权周期=>用户下注详细

    mapping(uint256 => mapping(uint256 => address)) public betUsers; //期权周期=>toeknId=>用户

    mapping(address => uint256[]) public userRounds; //

    AggregatorV3Interface internal oracle; //预言机

    IDefxNFTFactory public nftFactory;

    IERC20 dftToken;

    modifier onlyAdmin() {
        require(msg.sender == adminAddress, "admin: wut?");
        _;
    }

    modifier onlyOperator() {
        require(msg.sender == operatorAddress, "operator: wut?");
        _;
    }

    modifier onlyAdminOrOperator() {
        require(msg.sender == adminAddress || msg.sender == operatorAddress, "admin | operator: wut?");
        _;
    }

    modifier notContract() {
        require(!_isContract(msg.sender), "contract not allowed");
        require(msg.sender == tx.origin, "proxy contract not allowed");
        _;
    }

    function initialize( 
        address _adminAddress,
        address _operatorAddress,
        uint256 _intervalBlocks,
        uint256 _bufferBlocks,
        uint256 _minBetAmount,
        uint8 _roundRewardLevel,
        address _oracle,
        address  _nftTokenFactory,
        address _dftToken
        ) public initializer  {
            adminAddress = _adminAddress;
            operatorAddress = _operatorAddress;
            intervalBlocks = _intervalBlocks;
            bufferBlocks = _bufferBlocks;
            roundRewardLevel = _roundRewardLevel;
            nftFactory = IDefxNFTFactory(_nftTokenFactory);
            minBetAmount =  _minBetAmount;
            oracle = AggregatorV3Interface(_oracle);
            dftToken = IERC20(_dftToken);
    }

    /**
     * @dev set admin address
     * callable by owner
     */
    function setAdmin(address _adminAddress) external onlyAdmin {
        require(_adminAddress != address(0), "Cannot be zero address");
        adminAddress = _adminAddress;
    }

    /**
     * @dev set operator address
     * callable by admin
     */
    function setOperator(address _operatorAddress) external onlyAdmin {
        require(_operatorAddress != address(0), "Cannot be zero address");
        operatorAddress = _operatorAddress;
    }

    /**
     * @dev set interval blocks
     * callable by admin
     */
    function setIntervalBlocks(uint256 _intervalBlocks) external onlyAdmin {
        intervalBlocks = _intervalBlocks;
    }

    function setRoundRewardAmount(uint256 _roundRewardAmount) external onlyAdmin {
        roundRewardAmount = _roundRewardAmount;
    }

    /**
     * @dev set buffer blocks
     * callable by admin
     */
    function setBufferBlocks(uint256 _bufferBlocks) external onlyAdmin {
        require(_bufferBlocks <= intervalBlocks, "Cannot be more than intervalBlocks");
        bufferBlocks = _bufferBlocks;
    }

    /**
     * @dev set minBetAmount
     * callable by admin
     */
    function setMinBetAmount(uint256 _minBetAmount) external onlyAdmin {
        minBetAmount = _minBetAmount;
    }

      /**
     * @dev Start genesis round/ 创建合约后开启一个期权
     */
    function genesisStartRound() external onlyOperator whenNotPaused {
        require(!genesisStartOnce, "Can only run genesisStartRound once");
        _getRoundRewardAmount();
        currentEpoch = currentEpoch + 1;
        _startRound(currentEpoch);
        genesisStartOnce = true;
    }

     /**
     *  当前区块等于大于当前进行期权的lockNumber时访问
     * @dev Start the next round n, lock price for round n-1, end round n-2
     */
    function executeRound() external onlyOperator whenNotPaused {
        require(
            genesisStartOnce,
            "Can only run after genesisStartRound and genesisLockRound is triggered"
        );
        _getRoundRewardAmount();
        _safeEndRound(currentEpoch);
        // Increment currentEpoch to current round (n)
        currentEpoch = currentEpoch + 1;
        _safeStartRound(currentEpoch);
    }

    function setRoundRewardLevel(uint8 level) public onlyOperator {
        roundRewardLevel = level;
    }

     /**
     * @dev set Oracle address
     * callable by admin
     */
    function setOracle(address _oracle) external onlyAdmin {
        require(_oracle != address(0), "Cannot be zero address");
        oracle = AggregatorV3Interface(_oracle);
    }

    /**
     * 结算收益
     * @dev Claim reward
     */
    function claim(uint256 epoch, uint256 tokenId) external payable notContract {
        require(rounds[epoch].startBlock != 0, "Round has not started");
        //require(block.number > rounds[epoch].endBlock, "Round has not ended");
        require(!ledger[epoch][tokenId].claimed, "Rewards claimed");
        require(betUsers[epoch][tokenId] == msg.sender, "not your bet");
        uint256 reward;
        // Round valid, claim rewards
        if (rounds[epoch].oracleCalled) {
            uint8 level = claimable(epoch,tokenId);
            require(level!= 0, "Not eligible for claim");
            Round memory round = rounds[epoch];
            reward = round.rewardAmount.div(rounds[epoch].roundRewardLevel).div(level);
            require(dftToken.transfer(msg.sender, reward), "transfer fail");
         
        }
        BetInfo storage betInfo = ledger[epoch][tokenId];
        betInfo.claimed = true;
        emit Claim(msg.sender, epoch, reward, betInfo.nftTokenId,betInfo.startPoint);
    }


    function bets(uint256[] memory tokenIds) external  whenNotPaused  {
        for(uint256 i = 0; i< tokenIds.length; i++ ) {
            uint256 tokenId = tokenIds[i];
            _bet(tokenId);
        }
    }

    function bet(uint256 tokenId) external  whenNotPaused  {
        _bet(tokenId);
    }

          /**
     * @dev called by the admin to pause, triggers stopped state
     */
    function pause() public onlyAdminOrOperator whenNotPaused {
        _pause();

        emit Pause(currentEpoch);
    }

    /**
     * @dev called by the admin to unpause, returns to normal state
     * Reset genesis state. Once paused, the rounds would need to be kickstarted by genesis
     */
    function unpause() public onlyAdmin whenPaused {
        genesisStartOnce = false;
        _unpause();

        emit Unpause(currentEpoch);
    }

    /**
     * @dev Get the claimable stats of specific epoch and user account
     */
    function claimable(uint256 epoch, uint256 tokenId) public view returns (uint8) {
        BetInfo memory betInfo = ledger[epoch][tokenId];
        Round memory round = rounds[epoch];
        if(!round.oracleCalled) {
            return 0;
        }
        if(round.totalPonits == 0) {
            return 0;
        }
        uint level = round.roundRewardLevel;
        uint256 totalPoint = round.totalPonits;
        uint256 winerNumber = round.winnerNumber % totalPoint;
        uint256 win = winerNumber + 1;
        //理论获奖的个数
        uint256 winnerCount = level.add(1).mul(10).div(2).mul(level).div(10);
        //步长
        uint256 step = totalPoint.div(winnerCount);
        step = step == 0 ? 1: step;
        for(uint8 i = 0; i < level; i ++) {
            for(uint8 j = 0; j <= i; j++) {
                if(win <= totalPoint) {
                   if(betInfo.startPoint < win && betInfo.endPoint >= win) {
                       return i + 1;
                   }
                } else if(win < totalPoint + winerNumber) {
                   uint256 realWin = win % totalPoint;
                   if(betInfo.startPoint < realWin && betInfo.endPoint >= realWin) {
                       return i + 1;
                   }
                }
                win = win + step;
             }
        }
        return 0;
    }

    /**
     * @dev Get the refundable stats of specific epoch and user account
     */
    function refundable(uint256 epoch, uint256 tokenId) public view returns (bool) {
        BetInfo memory betInfo = ledger[epoch][tokenId];
        Round memory round = rounds[epoch];
        return !round.oracleCalled && betInfo.nftTokenId != 0;
    }

    function _bet(uint256 tokenId) internal {
        require(_bettable(currentEpoch), "Round not bettable");
        require(msg.sender == nftFactory.ownerOf(tokenId), "no your nft");
        uint256 point;
        uint256 epoch;
        //bool oracleCalled;
        (point,,epoch,) = nftFactory.getNFT(tokenId);
        nftFactory.safeTransferFrom(msg.sender, address(nftFactory), tokenId);
        betUsers[currentEpoch][tokenId] = msg.sender;
        Round storage round = rounds[currentEpoch];

         // Update user data
        BetInfo storage betInfo = ledger[currentEpoch][tokenId];
        betInfo.nftTokenId = tokenId;
        betInfo.startPoint = round.totalPonits;
        betInfo.point =  point;
        round.totalPonits +=  betInfo.point;
        betInfo.endPoint = round.totalPonits;

        emit Bet(msg.sender, currentEpoch, tokenId, betInfo.startPoint, betInfo.endPoint);
    }

     /**
     * @dev Start round
     * Previous round n-2 must end
     */
    function _safeStartRound(uint256 epoch) internal {
          require(genesisStartOnce, "Can only run after genesisStartRound is triggered");
        //require(block.number >= rounds[epoch - 1].endBlock, "Can only start new round after round n-1 endBlock");
        _startRound(epoch);
    }

    function _startRound(uint256 epoch) internal {
        Round storage round = rounds[epoch];
        round.startBlock = block.number;
        round.endBlock = block.number.add(intervalBlocks);
        round.epoch = epoch;
        round.rewardAmount = roundRewardAmount;
        round.roundRewardLevel = roundRewardLevel;
        emit StartRound(epoch, round.startBlock, round.endBlock, round.rewardAmount, roundRewardLevel);
    }

    /**
     * @dev End round
     */
    function _safeEndRound(uint256 epoch) public onlyOperator{
        //require(block.number >= rounds[epoch].endBlock, "Can only end round after endBlock");
        //require(block.number <= rounds[epoch].endBlock.add(bufferBlocks), "Can only end round within bufferBlocks");
        _endRound(epoch);
    }

    function _endRound(uint256 epoch) internal {
        Round storage round = rounds[epoch];
        round.randomNumber = (uint256)(_getPriceFromOracle());
        if(round.totalPonits > 0 ) {
            round.winnerNumber = uint256(keccak256(abi.encodePacked(
            (round.totalPonits).add   
            (block.timestamp).add
            (block.difficulty).add
            (round.randomNumber).add
            ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (block.timestamp)).add
            (block.gaslimit).add
            ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (block.timestamp)).add
            (block.number)
            )));
        }
        round.oracleCalled = true;
        emit EndRound(epoch, block.number, round.winnerNumber);
    }

    function _getRoundRewardAmount() internal {
        roundRewardAmount = minBetAmount;
    }

    function _safeTransferBNB(address to, uint256 value) internal {
        (bool success, ) = to.call{gas: 23000, value: value}("");
        require(success, "TransferHelper: BNB_TRANSFER_FAILED");
    }

     /**
     * @dev Determine if a round is valid for receiving bets
     * Round must have started and locked
     * Current block must be within startBlock and endBlock
     */
    function _bettable(uint256 epoch) internal view returns (bool) {
        return
            rounds[epoch].startBlock != 0 &&
            block.number < rounds[epoch].endBlock &&
            block.number >= rounds[epoch].startBlock &&
            !rounds[epoch].oracleCalled;
    }

    /**
     * @dev Get latest recorded price from oracle
     * If it falls below allowed buffer or has not updated, it would be invalid
     */
    function _getPriceFromOracle() internal view returns (int256) {
        (,int256 price,,,) = oracle.latestRoundData();
        return price;
    }

    function _isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }
    
    receive() external payable {
    }

    fallback() external payable {
    }
}
