// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../interface/IDefxNFTFactory.sol";
import "../interface/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract BNBLottery  is Pausable, Initializable{

    using SafeMath for uint256;

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
     * @dev Start genesis round/ 
     */
    function genesisStartRound() external onlyOperator whenNotPaused {
        require(!genesisStartOnce, "Can only run genesisStartRound once");
        _getRoundRewardAmount();
        currentEpoch = currentEpoch + 1;
        _startRound(currentEpoch);
        genesisStartOnce = true;
    }

     /**
     *  
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
