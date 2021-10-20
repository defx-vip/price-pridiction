// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import '../interface/ITokenBonusSharePool.sol';
import '../interface/IDFVToken.sol';
import "../interface/Routerv2.sol";
import "../interface/IDefxERC20.sol";
import "../interface/IDefxNFTFactory.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../interface/IUserRelation.sol";

contract TokenBonusSharePool is ITokenBonusSharePool,Ownable {

    using SafeMath for uint256;

    event PredictionBet(address source, address superior, uint256 amount, uint256 fee,uint256 reward, uint8 ptype);

    event ShareToDFV(address source, address superior, uint256 amount);

    event BrokerToDFT(address source, uint256 amount);

    event AirDrop(address onwernAddress, address recipient, uint256 nft);

    event TreasuryClaim(address operator, uint256 amount);

    address public dfvToken;
    address public defxToken;
    address public shareToken;
    Routerv2 public routerv2;
    IDefxNFTFactory defxNFTFactory;
    address public userRelation;

    mapping(address => uint256) public superiorShares; 
    mapping(address => uint256) public brokerShares; 
    uint256 public deadlineTime;
    uint256 public treasuryAmount; //给合约维护者的返佣

    uint256 public TOTAL_RATE = 100; // 100%
    uint256 public dfvRate = 20; // dfv比例
    uint256 public treasuryRate = 80; // 80

    address[] public swapTokens;
    
    constructor(
        address _dfvToken,
        address _defxToken,
        address _shareToken,
        address _routerv2,
        address _defxNFTFactory,
        address _userRelation,
        uint256 _deadlineTime
    ) {
        dfvToken = _dfvToken;
        defxToken = _defxToken;
        shareToken = _shareToken;
        routerv2 = Routerv2(_routerv2);
        defxNFTFactory = IDefxNFTFactory(_defxNFTFactory);
        userRelation =  _userRelation;
        deadlineTime = _deadlineTime;
        swapTokens = new address[](2);
        swapTokens[0] = shareToken;
        swapTokens[1] = defxToken;
    }

    function predictionBet(address source, uint256 tradeAmount, uint256 relAmount) external payable override {
        require(relAmount >  0 &&  IERC20(shareToken).transferFrom(msg.sender, address(this), relAmount), 
            "transferFrom error"
        );
        (address superior,,,) =  IUserRelation(userRelation).getUserInfo(source);
        if(source == address(0x0) || superior == address(0x0)) {
          treasuryAmount = treasuryAmount.add(relAmount);  
          return;  
        }
        (address superior1, bool isBroker1, ,uint8 rewardRate1) =  IUserRelation(userRelation).getUserInfo(superior);
        (, bool isBroker2,,) =  IUserRelation(userRelation).getUserInfo(superior1);
        uint256 amount;
        if(isBroker2) {
            amount = relAmount.mul(70).div(100);
            treasuryAmount = treasuryAmount.add(relAmount.sub(amount));
            uint256 superiorReward = amount.mul(rewardRate1).div(100);
            brokerShares[superior]  = brokerShares[superior].add(superiorReward);
            brokerShares[superior1]  = brokerShares[superior1].add(amount.sub(superiorReward));
            emit PredictionBet(source, superior, tradeAmount, relAmount , superiorReward, 1);
            emit PredictionBet(superior, superior1, 0, 0, amount.sub(superiorReward), 2);
        } else if(isBroker1) {
            amount = relAmount.mul(70).div(100);
            treasuryAmount = treasuryAmount.add(relAmount.sub(amount));
            brokerShares[superior]  = brokerShares[superior].add(amount);
            emit PredictionBet(source, superior, tradeAmount, relAmount, amount, 1);
        } else {
            amount = relAmount.mul(dfvRate).div(TOTAL_RATE);
            treasuryAmount = treasuryAmount.add(relAmount.sub(amount));
            superiorShares[superior]  = superiorShares[superior].add(amount);
            emit PredictionBet(source, superior, tradeAmount, relAmount, amount, 0);
        }
    }

    function superiorShare(address user) external view returns(uint256) {
        uint256 amount = superiorShares[user];
        if(amount == 0) {
            return 0;
        }
    
        uint256[] memory arr  = routerv2.getAmountsOut(amount, swapTokens);
        return arr[1];
    }

    function brokerShare(address user) external view returns(uint256) {
        uint256 amount = brokerShares[user];
        if(amount == 0) {
            return 0;
        }
        uint256[] memory arr  = routerv2.getAmountsOut(amount, swapTokens);
        return arr[1];
    }

    function superiorShareToDFV() external {
       IDFVToken vToken = IDFVToken(dfvToken);
       uint256 amount = superiorShares[msg.sender];
       require(amount > 0, "not balance");
       superiorShares[msg.sender] = 0;
      
       IERC20(shareToken).approve(address(routerv2), amount);
       uint[] memory amounts = routerv2.swapExactTokensForTokens(amount, 0, swapTokens, address(this), block.timestamp.add(deadlineTime)); 
       address superior =  vToken.getSuperior(msg.sender);
       IDefxERC20(defxToken).approve(dfvToken, amounts[1]);
       vToken.mintToUser(amounts[1], msg.sender);
       emit ShareToDFV(msg.sender, superior, amounts[1]);   
    }

    function brokerShareToDFT() external {
       uint256 amount = brokerShares[msg.sender];
       require(amount > 0, "not balance");
       superiorShares[msg.sender] = 0;
       IERC20(shareToken).approve(address(routerv2), amount);
       uint[] memory amounts = routerv2.swapExactTokensForTokens(amount, 0, swapTokens, address(this), block.timestamp.add(deadlineTime)); 
       IDefxERC20(defxToken).transfer(msg.sender, amounts[1]);
       emit BrokerToDFT(msg.sender, amounts[1]);   
    }
   
    function airDrop(uint256[] memory nfts, address[] calldata users) external override onlyOwner{
        for(uint i = 0; i < nfts.length; i++) {
            defxNFTFactory.safeTransferFrom(msg.sender, users[i], nfts[i]);
            emit AirDrop(msg.sender, users[i], nfts[i]);
        }
    }

    function setDeadlineTime(uint256 _deadlineTime) external onlyOwner{
        deadlineTime = _deadlineTime;
    }

     /**
     * @dev set reward rate /设置盈利率
     * callable by admin
     */
    function setDfvRate(uint256 _dfvRate) external onlyOwner {
        require(_dfvRate <= TOTAL_RATE, "rewardRate cannot be more than 100%");
        dfvRate = _dfvRate;
        treasuryRate = TOTAL_RATE.sub(_dfvRate);
    }

    /**
     * @dev set treasury rate
     * callable by admin
     */
    function setTreasuryRate(uint256 _treasuryRate) external onlyOwner {
        require(_treasuryRate <= TOTAL_RATE, "treasuryRate cannot be more than 100%");
        dfvRate = TOTAL_RATE.sub(_treasuryRate);
        treasuryRate = _treasuryRate;
    }

    function claimTreasury() external payable onlyOwner {
        uint256 currentTreasuryAmount = treasuryAmount;
        treasuryAmount = 0;
        IERC20(shareToken).transfer(msg.sender, currentTreasuryAmount);
        emit TreasuryClaim(msg.sender, currentTreasuryAmount);
    }

    function setSwapTokens(address[] memory _swapTokens) external onlyOwner{
        require(_swapTokens[0] == shareToken && _swapTokens[_swapTokens.length -1] == defxToken, "_swapTokens error");
        delete swapTokens;
        swapTokens = _swapTokens;
    }
}