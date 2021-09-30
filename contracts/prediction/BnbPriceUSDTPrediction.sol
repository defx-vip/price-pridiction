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

contract BnbPriceUSDTPrediction is Ownable, Pausable,Initializable {
    
    using SafeMath for uint256;

    //
    enum Position {Bull, Bear}

    //期权周期
    struct Round {
        uint256 epoch; //index
        uint256 startBlock; //开始区块
        uint256 lockBlock; //锁的区块
        uint256 endBlock; //结算区块
        int256 lockPrice; //锁定价格
        int256 closePrice; //结算价格
        uint256 totalAmount; //投注总金额
        uint256 bullAmount; //看涨金额
        uint256 bearAmount; //看跌金额
        uint256 rewardBaseCalAmount; //赢家投注金额
        uint256 rewardAmount; //赢家金额
        bool oracleCalled; //是否已经获取价格
    }

    //赌注即订单
    struct BetInfo {
        Position position; //看涨或者看跌
        uint256 amount; //金额
        bool claimed; // 是否需要领取
        uint256 nftTokenId;
    }

    bool public genesisStartOnce = false; //是否调用初始化开始方法

    bool public genesisLockOnce = false; //是否调用初始化锁定方法

    uint256 public currentEpoch; //当前周期角标

    uint256 public intervalBlocks; //100

    uint256 public bufferBlocks; //15

    address public adminAddress; //管理员地址

    address public operatorAddress; //操作员地址

    uint256 public oracleLatestRoundId;

    uint256 public TOTAL_RATE; // 100%

    uint256 public rewardRate; // 90% 赢家比率

    uint256 public treasuryRate; // 10% 合约维护者佣金比率

    uint256 public minBetAmount; //最小投资金额

    uint256 public oracleUpdateAllowance; // seconds 允许价格相差的时间

    mapping(uint256 => Round) public rounds; //期权周期mapping, currentEpoch

    mapping(uint256 => mapping(address => BetInfo)) public ledger; //期权周期=>用户下注详细

    mapping(address => uint256[]) public userRounds; //

    IDefxNFTFactory public nftTokenFactory;

    AggregatorV3Interface internal oracle; //预言机

    ITokenBonusSharePool public bonusSharePool; //分红

    IERC20 public betToken;

    event StartRound(uint256 indexed epoch, uint256 blockNumber, uint256 intervalBlocks);

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
        AggregatorV3Interface _oracle,
        address _adminAddress,
        address _operatorAddress,
        uint256 _intervalBlocks,
        uint256 _bufferBlocks,
        uint256 _minBetAmount,
        uint256 _TOTAL_RATE,
        uint256 _rewardRate,
        uint256 _treasuryRate,
        uint256 _oracleUpdateAllowance,
        IDefxNFTFactory  _nftTokenFactory) public initializer {
            oracle = _oracle;
            adminAddress = _adminAddress;
            operatorAddress = _operatorAddress;
            intervalBlocks = _intervalBlocks;
            bufferBlocks = _bufferBlocks;
            minBetAmount = _minBetAmount;
            TOTAL_RATE = _TOTAL_RATE;
            rewardRate = _rewardRate;
            treasuryRate = _treasuryRate;
            oracleUpdateAllowance = _oracleUpdateAllowance;
            nftTokenFactory = _nftTokenFactory;
            betToken = IERC20(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7);
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

    /**
     * @dev set buffer blocks
     * callable by admin
     */
    function setBufferBlocks(uint256 _bufferBlocks) external onlyAdmin {
        require(_bufferBlocks <= intervalBlocks, "Cannot be more than intervalBlocks");
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
    function setRewardRate(uint256 _rewardRate) external onlyAdmin {
        require(_rewardRate <= TOTAL_RATE, "rewardRate cannot be more than 100%");
        rewardRate = _rewardRate;
        treasuryRate = TOTAL_RATE.sub(_rewardRate);

        emit RatesUpdated(currentEpoch, rewardRate, treasuryRate);
    }

    /**
     * @dev set treasury rate
     * callable by admin
     */
    function setTreasuryRate(uint256 _treasuryRate) external onlyAdmin {
        require(_treasuryRate <= TOTAL_RATE, "treasuryRate cannot be more than 100%");
        rewardRate = TOTAL_RATE.sub(_treasuryRate);
        treasuryRate = _treasuryRate;

        emit RatesUpdated(currentEpoch, rewardRate, treasuryRate);
    }

    /**
     * @dev set minBetAmount
     * callable by admin
     */
    function setMinBetAmount(uint256 _minBetAmount) external onlyAdmin {
        minBetAmount = _minBetAmount;

        emit MinBetAmountUpdated(currentEpoch, minBetAmount);
    }

    function setBonusSharePool(address _bonusSharePool) external onlyAdmin{
        bonusSharePool = ITokenBonusSharePool(_bonusSharePool);
    }

    function setBetToken(address _betToken) external onlyAdmin {
        betToken = IERC20(_betToken);
    }
    /**
     * @dev Start genesis round/ 
     */
    function genesisStartRound() external onlyAdminOrOperator whenNotPaused {
        require(!genesisStartOnce, "Can only run genesisStartRound once");
        currentEpoch = currentEpoch + 1;
        _startRound(currentEpoch, getRoundStartBlock());
        genesisStartOnce = true;
    }

    /**
     * @dev Lock genesis round/ 
     */
    function genesisLockRound() external onlyAdminOrOperator whenNotPaused {
        require(genesisStartOnce, "Can only run after genesisStartRound is triggered");
        require(!genesisLockOnce, "Can only run genesisLockRound once");
        require(
            block.number <= rounds[currentEpoch].lockBlock.add(bufferBlocks),
            "Can only lock round within bufferBlocks"
        );

        int256 currentPrice = _getPriceFromOracle();
        _safeLockRound(currentEpoch, currentPrice);

        currentEpoch = currentEpoch + 1;
        _startRound(currentEpoch, getRoundStartBlock());
        genesisLockOnce = true;
    }

    /**
     *  
     * @dev Start the next round n, lock price for round n-1, end round n-2
     */
    function executeRound() external onlyAdminOrOperator whenNotPaused {
        require(
            genesisStartOnce && genesisLockOnce,
            "Can only run after genesisStartRound and genesisLockRound is triggered"
        );

        int256 currentPrice = _getPriceFromOracle();
        // CurrentEpoch refers to previous round (n-1)
        _safeLockRound(currentEpoch, currentPrice);
        _safeEndRound(currentEpoch - 1, currentPrice);
        _calculateRewards(currentEpoch - 1);

        // Increment currentEpoch to current round (n)
        currentEpoch = currentEpoch + 1;
        _safeStartRound(currentEpoch);
    }

    /**
     * @dev Bet bear position
     */
    function betBear(uint256 amount) external payable whenNotPaused notContract {
        require(_bettable(currentEpoch), "Round not bettable");
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
        betToken.approve(address(bonusSharePool), fee);
        bonusSharePool.predictionBet(msg.sender, amount, fee);
        emit BetBear(msg.sender, currentEpoch, amount, betInfo.nftTokenId);
    }

    /**
     * @dev Bet bull position
     */
    function betBull(uint256 amount) external payable whenNotPaused notContract {
        require(_bettable(currentEpoch), "Round not bettable");
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
        betToken.approve(address(bonusSharePool), fee);
        bonusSharePool.predictionBet(msg.sender, amount, fee);
        emit BetBull(msg.sender, currentEpoch, amount, betInfo.nftTokenId);
    }

    /**
     * 结算收益
     * @dev Claim reward
     */
    function claim(uint256 epoch) external payable notContract returns(uint256){
        require(rounds[epoch].startBlock != 0, "Round has not started");
        require(block.number > rounds[epoch].endBlock, "Round has not ended");
        require(!ledger[epoch][msg.sender].claimed, "Rewards claimed");
        require(ledger[epoch][msg.sender].amount > 0, "not bet");
        BetInfo storage betInfo = ledger[epoch][msg.sender];
        uint256 reward;
        uint256 nftToken = 0;
        // Round valid, claim rewards
        if (rounds[epoch].oracleCalled) {
            if(claimable(epoch, msg.sender)) {
                Round memory round = rounds[epoch];
                reward = ledger[epoch][msg.sender].amount.mul(round.rewardAmount).div(round.rewardBaseCalAmount);
                require(betToken.transfer(msg.sender, reward), "transfer error");
            } else {
                betInfo.nftTokenId = nftTokenFactory.doMint(msg.sender, currentEpoch, betInfo.amount);
                nftToken = betInfo.nftTokenId;
            }
        } 
        // Round invalid, refund bet amount
        else {
            require(refundable(epoch, msg.sender), "Not eligible for refund");
            reward = ledger[epoch][msg.sender].amount;
            require(betToken.transfer(msg.sender, reward), "transfer error");
        }
        betInfo.claimed = true;
        emit Claim(msg.sender, epoch, reward, betInfo.nftTokenId);
        return nftToken;
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
    function unpause() public onlyAdminOrOperator whenPaused {
        genesisStartOnce = false;
        genesisLockOnce = false;
        _unpause();

        emit Unpause(currentEpoch);
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
     * @dev Get the claimable stats of specific epoch and user account
     */
    function claimable(uint256 epoch, address user) public view returns (bool) {
        BetInfo memory betInfo = ledger[epoch][user];
        Round memory round = rounds[epoch];
        if (round.lockPrice == round.closePrice) {
            return false;
        }
        return
            round.oracleCalled &&
            ((round.closePrice > round.lockPrice && betInfo.position == Position.Bull) ||
                (round.closePrice < round.lockPrice && betInfo.position == Position.Bear));
    }

    /**
     * @dev Get the refundable stats of specific epoch and user account
     */
    function refundable(uint256 epoch, address user) public view returns (bool) {
        BetInfo memory betInfo = ledger[epoch][user];
        Round memory round = rounds[epoch];
        return !round.oracleCalled && block.number > round.endBlock.add(bufferBlocks) && betInfo.amount != 0;
    }

    function indexRound(uint256 epoch) external view
        returns(
            uint256 startBlock,
            uint256 lockBlock,
            uint256 endBlock,
            bool oracleCalled
        ) {
            if(epoch == 0) {
                epoch = currentEpoch;
            }
            Round memory round = rounds[epoch];
            return (round.startBlock, round.lockBlock, round.endBlock, round.oracleCalled);
    }

    /**
     * @dev Start round
     * Previous round n-2 must end
     */
    function _safeStartRound(uint256 epoch) internal {
        uint256 startBlock = getRoundStartBlock();
        require(genesisStartOnce, "Can only run after genesisStartRound is triggered");
        require(rounds[epoch - 2].endBlock != 0, "Can only start round after round n-2 has ended");
        require(startBlock >= rounds[epoch - 2].lockBlock, "Can only start new round after round n-2 endBlock");
        _startRound(epoch, startBlock);
    }

    function _startRound(uint256 epoch, uint256 startBlock) internal {
        Round storage round = rounds[epoch];
        round.startBlock = startBlock;
        round.lockBlock = startBlock.add(intervalBlocks);
        round.endBlock = startBlock.add(intervalBlocks * 2);
        round.epoch = epoch;
        round.totalAmount = 0;

        emit StartRound(epoch, startBlock, intervalBlocks);
    }

    /**
     * @dev Lock round
     */
    function _safeLockRound(uint256 epoch, int256 price) internal {
        require(rounds[epoch].startBlock != 0, "Can only lock round after round has started");
        require(block.number >= rounds[epoch].lockBlock, "Can only lock round after lockBlock");
        require(block.number <= rounds[epoch].lockBlock.add(bufferBlocks), "Can only lock round within bufferBlocks");
        _lockRound(epoch, price);
    }

    function _lockRound(uint256 epoch, int256 price) internal {
        Round storage round = rounds[epoch];
        round.lockPrice = price;

        emit LockRound(epoch, block.number, round.lockPrice);
    }

    /**
     * @dev End round
     */
    function _safeEndRound(uint256 epoch, int256 price) internal {
        require(rounds[epoch].lockBlock != 0, "Can only end round after round has locked");
        require(block.number.add(intervalBlocks) >= rounds[epoch].endBlock, "Can only end round after endBlock");
        require(block.number <= rounds[epoch].endBlock.add(bufferBlocks), "Can only end round within bufferBlocks");
        _endRound(epoch, price);
    }

    function _endRound(uint256 epoch, int256 price) internal {
        Round storage round = rounds[epoch];
        round.closePrice = price;
        round.oracleCalled = true;

        emit EndRound(epoch, block.number, round.closePrice);
    }

    /**
     * @dev Calculate rewards for round
     */
    function _calculateRewards(uint256 epoch) internal {
        require(rewardRate.add(treasuryRate) == TOTAL_RATE, "rewardRate and treasuryRate must add up to TOTAL_RATE");
        require(rounds[epoch].rewardBaseCalAmount == 0 && rounds[epoch].rewardAmount == 0, "Rewards calculated");
        Round storage round = rounds[epoch];
        uint256 rewardBaseCalAmount;
        uint256 rewardAmount;
        uint256 treasuryAmt;
        // Bull wins
        if (round.closePrice > round.lockPrice) {
            rewardBaseCalAmount = round.bullAmount;
            rewardAmount = round.totalAmount.mul(rewardRate).div(TOTAL_RATE);
            treasuryAmt = round.totalAmount.mul(treasuryRate).div(TOTAL_RATE);
        }
        // Bear wins
        else if (round.closePrice < round.lockPrice) {
            rewardBaseCalAmount = round.bearAmount;
            rewardAmount = round.totalAmount.mul(rewardRate).div(TOTAL_RATE);
            treasuryAmt = round.totalAmount.mul(treasuryRate).div(TOTAL_RATE);
        }
        // House wins
        else {
            rewardBaseCalAmount = 0;
            rewardAmount = 0;
            treasuryAmt = round.totalAmount;
            uint256 reward = round.totalAmount.mul(rewardRate).div(TOTAL_RATE);
            betToken.approve(address(bonusSharePool), reward);
            bonusSharePool.predictionBet(address(0x0), 0, reward);
        }
        round.rewardBaseCalAmount = rewardBaseCalAmount;
        round.rewardAmount = rewardAmount;

        emit RewardsCalculated(epoch, rewardBaseCalAmount, rewardAmount, treasuryAmt);
    }

    /**
     * @dev Get latest recorded price from oracle
     * If it falls below allowed buffer or has not updated, it would be invalid
     */
    function _getPriceFromOracle() internal returns (int256) {
        uint256 leastAllowedTimestamp = block.timestamp.add(oracleUpdateAllowance);
        (uint80 roundId, int256 price, , uint256 timestamp, ) = oracle.latestRoundData();
        require(timestamp <= leastAllowedTimestamp, "Oracle update exceeded max timestamp allowance");
        require(roundId > oracleLatestRoundId, "Oracle update roundId must be larger than oracleLatestRoundId");
        oracleLatestRoundId = uint256(roundId);
        return price;
    }

    function _safeTransferBNB(address to, uint256 value) internal {
        (bool success, ) = to.call{gas: 23000, value: value}("");
        require(success, "TransferHelper: BNB_TRANSFER_FAILED");
    }

    function transferForeignToken(address _token, address _to) public onlyAdmin returns(bool _sent){
        require(_token != address(this), "Can't let you take all native token");
        uint256 _contractBalance = IERC20(_token).balanceOf(address(this));
        _sent = IERC20(_token).transfer(_to, _contractBalance);
    }

    function Sweep() external onlyAdmin {
        uint256 balance = address(this).balance;
        payable(owner()).transfer(balance);
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
    function _bettable(uint256 epoch) internal view returns (bool) {
        return
            rounds[epoch].startBlock != 0 &&
            rounds[epoch].lockBlock != 0 &&
            block.number >= rounds[epoch].startBlock &&
            block.number < rounds[epoch].lockBlock;
    }
    
    //获取整点区块
    function getRoundStartBlock() public view returns(uint256) {
        uint256 timeInterval = intervalBlocks * 3;
        uint256 mod =  block.timestamp.mod(timeInterval);
        uint256 inBlock = mod.div(3);
        uint256 blockNumber = block.number;
        if(inBlock > 10 && blockNumber > inBlock) {
            return blockNumber - inBlock;
        }
        return blockNumber;
    }
}
