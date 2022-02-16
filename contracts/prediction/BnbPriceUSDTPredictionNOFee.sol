// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../interface/AggregatorV3Interface.sol";
import "../interface/IDefxNFTFactory.sol";
import '../interface/ITokenBonusSharePool.sol';
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import '@openzeppelin/contracts/access/Ownable.sol';
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract BnbPriceUSDTPredictionNOFee is Ownable, Pausable,Initializable {
    
    using SafeMath for uint256;
    using SafeMath for uint80; 
    //
    enum Position {Bull, Bear}

    //期权周期
    struct Round {
        uint256 totalAmount; //投注总金额
        uint256 bullAmount; //看涨金额
        uint256 bearAmount; //看跌金额
    }

    //赌注即订单
    struct BetInfo {
        Position position; //看涨或者看跌
        uint256 amount; //金额
        bool claimed; // 是否需要领取
        uint256 nftTokenId;
    }

    uint256 public startTime; //开始时间

    uint256 public intervalTime; //100

    uint256 public bufferBlocks; //15

    address public adminAddress; //管理员地址

    address public operatorAddress; //操作员地址

    uint256 public oracleLatestRoundId;

    uint256 public TOTAL_RATE; // 100%

    uint256 public rewardRate; // 90% 赢家比率

    uint256 public treasuryRate; // 10% 合约维护者佣金比率

    uint256 public minBetAmount; //最小投资金额

    uint256 public oracleUpdateAllowance; // seconds 允许价格相差的时间

    mapping(uint256 => Round) public rounds; //期权周期mapping

    mapping(uint256 => mapping(address => BetInfo)) public ledger; //期权周期=>用户下注详细

    mapping(address => uint256[]) public userRounds; //

    IDefxNFTFactory public nftTokenFactory;

    AggregatorV3Interface internal oracle; //预言机

    ITokenBonusSharePool public bonusSharePool; //分红

    IERC20 public betToken;

    event StartRound(uint256 indexed epoch, uint256 blockNumber, uint256 intervalTime);

    event LockRound(uint256 indexed epoch, uint256 blockNumber, int256 price);

    event EndRound(uint256 indexed epoch, uint256 blockNumber, int256 price);

    event BetBull(address indexed sender, uint256 indexed currentEpoch, uint256 amount, uint256 nftTokenId);
    
    event BetBear(address indexed sender, uint256 indexed currentEpoch, uint256 amount, uint256 nftTokenId);
    
    event Claim(address indexed sender, uint256 indexed currentEpoch, uint256 amount, uint256 nftTokenId);
    
    event RatesUpdated(uint256 indexed epoch, uint256 rewardRate, uint256 treasuryRate);
    
    event MinBetAmountUpdated(uint256 indexed epoch, uint256 minBetAmount);
    
    event RewardsCalculated(uint256 indexed epoch, uint256 rewardBaseCalAmount, uint256 rewardAmount, uint256 treasuryAmount);
    
    event Pause(uint256 epoch);
    
    event Unpause(uint256 epoch);


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
        address _betToken,
        AggregatorV3Interface _oracle,
        address _adminAddress,
        address _operatorAddress,
        uint256 _intervalTime,
        uint256 _bufferBlocks,
        uint256 _minBetAmount,
        uint256 _TOTAL_RATE,
        uint256 _rewardRate,
        uint256 _treasuryRate,
        uint256 _oracleUpdateAllowance,
        IDefxNFTFactory  _nftTokenFactory) public initializer {
            oracle = _oracle;
            betToken = IERC20(_betToken);
            adminAddress = _adminAddress;
            operatorAddress = _operatorAddress;
            intervalTime = _intervalTime;
            bufferBlocks = _bufferBlocks;
            minBetAmount = _minBetAmount;
            TOTAL_RATE = _TOTAL_RATE;
            rewardRate = _rewardRate;
            treasuryRate = _treasuryRate;
            oracleUpdateAllowance = _oracleUpdateAllowance;
            nftTokenFactory = _nftTokenFactory;        
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
    function setIntervalTime(uint256 _intervalTime) external onlyAdmin {
        intervalTime = _intervalTime;
    }

    /**
     * @dev set buffer blocks
     * callable by admin
     */
    function setBufferBlocks(uint256 _bufferBlocks) external onlyAdmin {
        require(_bufferBlocks <= intervalTime, "Cannot be more than intervalTime");
        bufferBlocks = _bufferBlocks;
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
     * @dev set oracle update allowance
     * callable by admin
     */
    function setOracleUpdateAllowance(uint256 _oracleUpdateAllowance) external onlyAdmin {
        oracleUpdateAllowance = _oracleUpdateAllowance;
    }

    /**
     * @dev set reward rate /设置盈利率
     * callable by admin
     */
    function setRewardRate(uint256 _rewardRate) external onlyAdmin whenPaused{
        require(_rewardRate <= TOTAL_RATE, "rewardRate cannot be more than 100%");
        rewardRate = _rewardRate;
        treasuryRate = TOTAL_RATE.sub(_rewardRate);
    }

    /**
     * @dev set treasury rate
     * callable by admin
     */
    function setTreasuryRate(uint256 _treasuryRate) external onlyAdmin {
        require(_treasuryRate <= TOTAL_RATE, "treasuryRate cannot be more than 100%");
        rewardRate = TOTAL_RATE.sub(_treasuryRate);
        treasuryRate = _treasuryRate;
    }

    /**
     * @dev set minBetAmount
     * callable by admin
     */
    function setMinBetAmount(uint256 _minBetAmount) external onlyAdmin {
        minBetAmount = _minBetAmount;

      
    }

    function setBonusSharePool(address _bonusSharePool) external onlyAdmin{
        bonusSharePool = ITokenBonusSharePool(_bonusSharePool);
    }

    function setBetToken(address _betToken) external onlyAdmin {
        betToken = IERC20(_betToken);
    }
   
    function getCurrentEpoch() internal view returns(uint256){
       return block.timestamp.div(intervalTime) * intervalTime;
    }

    /**
     * @dev Bet bear position
     */
    function betBear(uint256 amount) external payable whenNotPaused notContract {
        uint256 currentEpoch = getCurrentEpoch();
        require(_bettable(), "Round not bettable");
        require(amount >= minBetAmount, "Bet amount must be greater than minBetAmount");
        require(betToken.transferFrom(msg.sender, address(this), amount), "transferFrom error");
        require(ledger[currentEpoch][msg.sender].amount == 0, "Can only bet once per round");

        // Update round data
        Round storage round = rounds[currentEpoch];
        round.totalAmount = round.totalAmount.add(amount);
        round.bearAmount = round.bearAmount.add(amount);

        // Update user data
        BetInfo storage betInfo = ledger[currentEpoch][msg.sender];
        betInfo.position = Position.Bear;
        betInfo.amount = amount;
        betInfo.nftTokenId = 0;
        userRounds[msg.sender].push(currentEpoch);
        uint256 fee = betInfo.amount.mul(treasuryRate).div(TOTAL_RATE);
        bonusSharePool.predictionBet(msg.sender, amount, fee);
        emit BetBear(msg.sender, currentEpoch, amount, betInfo.nftTokenId);
    }

    /**
     * @dev Bet bull position
     */
    function betBull(uint256 amount) external payable whenNotPaused notContract {
        uint256 currentEpoch = getCurrentEpoch();
        require(_bettable(), "Round not bettable");
        require(amount >= minBetAmount, "Bet amount must be greater than minBetAmount");
        require(betToken.transferFrom(msg.sender, address(this), amount), "transferFrom error");
        require(ledger[currentEpoch][msg.sender].amount == 0, "Can only bet once per round");

        // Update round data
        Round storage round = rounds[currentEpoch];
        round.totalAmount = round.totalAmount.add(amount);
        round.bullAmount = round.bullAmount.add(amount);

        // Update user data
        BetInfo storage betInfo = ledger[currentEpoch][msg.sender];
        betInfo.position = Position.Bull;
        betInfo.amount = amount;
        betInfo.nftTokenId = 0;
        userRounds[msg.sender].push(currentEpoch);
        uint256 fee = betInfo.amount.mul(treasuryRate).div(TOTAL_RATE); 
        bonusSharePool.predictionBet(msg.sender, amount, fee);
        emit BetBull(msg.sender, currentEpoch, amount, betInfo.nftTokenId);
    }

    function checkOracleRoundId(uint256 time, uint80 oracleRoundId) internal view returns( int256 answer, uint256 updateTime) {
        (, answer, , updateTime, ) = oracle.getRoundData(oracleRoundId);
        uint256 lastRoundId = oracle.latestRound();
        if(lastRoundId == oracleRoundId) {
            require(time <= updateTime, "oracleRoundId error");
        } else {
            (, , , uint256 timestamp, ) = oracle.getRoundData(oracleRoundId + 1);
            require(time <= updateTime && time < timestamp, "oracleRoundId error");
        }
    }

    struct SlotInfo { 
        uint256 reward;
        uint256 rewardBaseCalAmount;
        uint256 rewardAmount;
        Position win;
    }
    /**
     * 结算收益
     * @dev Claim reward
     */
    function claim(uint256 epoch, uint80 lockOracleRoundId, uint80 closeOracleRoundId) external payable notContract {
        require(block.timestamp > epoch.add(intervalTime.mul(2)), "Round has not ended");
        require(!ledger[epoch][msg.sender].claimed, "Rewards claimed");
        require(ledger[epoch][msg.sender].amount > 0, "not bet");
        BetInfo storage betInfo = ledger[epoch][msg.sender];
        SlotInfo memory s;
        uint256 closeTime = epoch.add(intervalTime.mul(2));
        (int256 lockPrice,) = checkOracleRoundId( epoch.add(intervalTime), lockOracleRoundId);
        (int256 closePrice, uint256 closeUpdateTime) = checkOracleRoundId(closeTime, closeOracleRoundId);
      
        if(closeUpdateTime.add(oracleUpdateAllowance) < closeTime ) { //chailink故障
            s.reward = ledger[epoch][msg.sender].amount.mul(rewardRate).div(TOTAL_RATE);
            require(betToken.transfer(msg.sender, s.reward), "transfer error");
        } else {
            Round memory round = rounds[epoch];
            if (closePrice > lockPrice) {
                s.rewardBaseCalAmount = round.bullAmount;
                s.rewardAmount = round.totalAmount.mul(rewardRate).div(TOTAL_RATE);
                s.win = Position.Bull;
            }
            // Bear wins
            else if (closePrice < lockPrice) {
                s.rewardBaseCalAmount = round.bearAmount;
                s.rewardAmount = round.totalAmount.mul(rewardRate).div(TOTAL_RATE);
                s.win = Position.Bull;
            }
            // House wins
            else {
                s.rewardBaseCalAmount = 0;
                s.rewardAmount = round.totalAmount.mul(rewardRate).div(TOTAL_RATE);
                if(s.rewardAmount > 0) {
                    bonusSharePool.predictionBet(address(0x0), 0, s.rewardAmount);
                }
            }
            uint256 cur = epoch;
            if(ledger[cur][msg.sender].position == s.win) {
                s.reward = ledger[cur][msg.sender].amount.mul(s.rewardAmount).div(s.rewardBaseCalAmount);
                require(betToken.transfer(msg.sender, s.reward), "transfer error");
            } else {
                betInfo.nftTokenId = nftTokenFactory.doMint(msg.sender, epoch, betInfo.amount);
            } 
        }
        betInfo.claimed = true;
        emit Claim(msg.sender, epoch, s.reward, betInfo.nftTokenId);
    }

    /**
     * @dev called by the admin to pause, triggers stopped state
     */
    function pause() public onlyAdminOrOperator whenNotPaused {
        _pause();
    }

    /**
     * @dev called by the admin to unpause, returns to normal state
     * Reset genesis state. Once paused, the rounds would need to be kickstarted by genesis
     */
    function unpause() public onlyAdminOrOperator whenPaused {
        _unpause();
    }

    /**
     * @dev Return round epochs that a user has participated
     */
    function getUserRounds(
        address user,
        uint256 cursor,
        uint256 size
    ) external view returns (uint256[] memory, uint256) {
        uint256 length = size;
        if (length > userRounds[user].length - cursor) {
            length = userRounds[user].length - cursor;
        }

        uint256[] memory values = new uint256[](length);
        for (uint256 i = 0; i < length; i++) {
            values[i] = userRounds[user][cursor + i];
        }

        return (values, cursor + length);
    }

 
    /**
     * 
     */
    function approveToStakingAddress() public onlyAdminOrOperator{
        betToken.approve(address(bonusSharePool), ~uint256(0));
    }


    
    function _safeTransferBNB(address to, uint256 value) internal {
        (bool success, ) = to.call{gas: 23000, value: value}("");
        require(success, "TransferHelper: BNB_TRANSFER_FAILED");
    }

    function _isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }

    /**
     * @dev Determine if a round is valid for receiving bets
     * Round must have started and locked
     * Current block must be within startBlock and endBlock
     */
    function _bettable() internal view returns (bool) {
        return block.timestamp >= startTime;
    }
    
  
}
