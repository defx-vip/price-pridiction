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

    event Deposit(address source, address superior, uint256 amount, string coin);

    event ShareToDFV(address source, address superior, uint256 amount);

    event ShareToDFT(address source, uint256 amount);

    event AirDrop(address onwernAddress, address recipient, uint256 nft);

    address public dfvToken;
    address public defxToken;
    address public shareToken;
    Routerv2 public routerv2;
    IDefxNFTFactory defxNFTFactory;
    address public userRelation;

    mapping(address => uint256) public superiorShares; 
    uint256 public deadlineTime;
    uint256 public shareAmount;
    uint256 public treasuryAmount; //给合约维护者的返佣

    uint256 public TOTAL_RATE = 100; // 100%
    uint256 public dfvRate = 20; // dfv比例
    uint256 public treasuryRate = 80; // 80
    
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
    }

    function deposit(address source, address _superior, uint256 relAmount) external payable override {
        require(relAmount >  0 &&  IERC20(shareToken).transferFrom(msg.sender, address(this), relAmount), 
            "transferFrom error"
        );
         (address superior, uint8 role, bool isBind) =  IUserRelation(userRelation).getUserInfo(source);
        if(source == address(0x0) || superior == address(0x0)) {
          treasuryAmount = treasuryAmount.add(relAmount);  
          return;  
        }
        
        uint256 amount;
        uint256 treasury;
        if(role == 2) { //is broker
            (address superior1,uint8 role1,) =  IUserRelation(userRelation).getUserInfo(superior);
            (,uint8 role2,) =  IUserRelation(userRelation).getUserInfo(superior1);
        } else if(role == 3) {

        } else {
            amount = relAmount.mul(dfvRate).div(TOTAL_RATE);
            treasury = relAmount.sub(amount);
            treasuryAmount = treasuryAmount.add(treasury);
            superiorShares[superior]  = superiorShares[superior].add(amount);
            shareAmount = shareAmount.add(amount);
        }
         emit Deposit(source, superior, amount, "USDT");
        
    }

    function superiorShare(address user) external view returns(uint256) {
        uint256 amount = superiorShares[user];
        if(amount == 0) {
            return 0;
        }
        address[] memory swapTokens = new address[](2);
        swapTokens[0] = shareToken ;
        swapTokens[1] = defxToken;
        uint256[] memory arr  = routerv2.getAmountsOut(amount, swapTokens);
        return arr[1];
    }

    function superiorShareToDFV() external {
       IDFVToken vToken = IDFVToken(dfvToken);
       uint256 amount = superiorShares[msg.sender];
       require(amount > 0, "not balance");
       superiorShares[msg.sender] = 0;
       shareAmount = shareAmount.sub(amount);
       address[] memory swapTokens = new address[](2);
       swapTokens[0] = shareToken;
       swapTokens[1] = defxToken;
       uint[] memory amounts = routerv2.swapExactTokensForTokens(amount, 0, swapTokens, address(this), block.timestamp.add(deadlineTime)); 
       address superior =  vToken.getSuperior(msg.sender);
       IDefxERC20(defxToken).approve(dfvToken, amounts[1]);
       vToken.mintToUser(amounts[1], msg.sender);
       emit ShareToDFV(msg.sender, superior, amounts[1]);   
    }

    function superiorShareToDFT() external {
       uint256 amount = superiorShares[msg.sender];
       require(amount > 0, "not balance");
       superiorShares[msg.sender] = 0;
       shareAmount = shareAmount.sub(amount);
       address[] memory swapTokens = new address[](2);
       swapTokens[0] = shareToken;
       swapTokens[1] = defxToken;
       uint[] memory amounts = routerv2.swapExactTokensForTokens(amount, 0, swapTokens, address(this), block.timestamp.add(deadlineTime)); 
       IDefxERC20(defxToken).transfer(msg.sender, amounts[1]);
       emit ShareToDFT(msg.sender, amounts[1]);   
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
    }

}