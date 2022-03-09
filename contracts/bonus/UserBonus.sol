 // SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../interface/IUserInfo.sol";
import "hardhat/console.sol";
import "../interface/IDefxNFTFactory.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract UserBonus {
    using SafeMath for uint256;
    event ExcuteLucky(address user, uint256 tokenId, uint256 bonusAmount);
    uint256 constant STEP_SIZE = 5 ;
    uint256 constant FIXED_AMOUNT_OF_CHECKINS = 1;
    uint256 constant BONUS_MULTIPLIER_BET = 10;
    uint256 constant CHECKIN_BONUS_FIXED_AMOUNT = 10 * 10**18;
    uint256 constant CHECKIN_BONUS_SETUP =  10**18;
    address public userInfo;
    address public token;
    mapping(address => uint256) public betAmounts;
    mapping(address => uint256) public bonusAmounts;
    mapping(address => bool) public allownUpdateBets;
    mapping(address => mapping(uint256 => uint256)) checkins;
    
    constructor(address _userInfo, address _token) {
        userInfo = _userInfo;
        token = _token;
        allownUpdateBets[msg.sender] = true;
    }

    modifier onlyUpdateBetUser() {
        require(allownUpdateBets[msg.sender], "allownUpdateBets: wut?");
        _;
    }

    function betting(address user, uint256 amount ) public {
        betAmounts[user] = betAmounts[user].add(amount);
    }

    function addBonus(address user, uint256 amount) public onlyUpdateBetUser {
        bonusAmounts[user] = bonusAmounts[user].add(amount);
    }

    function withdrawBonus(uint256 amount) public {
        require(amount <= betAmounts[msg.sender].div(BONUS_MULTIPLIER_BET), "error amount");
        require(amount <= bonusAmounts[msg.sender], "error amount");
        bonusAmounts[msg.sender] = bonusAmounts[msg.sender].sub(amount);
        betAmounts[msg.sender] = betAmounts[msg.sender].sub(amount.mul(BONUS_MULTIPLIER_BET));
        IERC20(token).transfer(msg.sender, amount);
    }

    function excuteLucky() public returns (uint256 bonusAmount) {
        IUserInfo userInfoImpl = IUserInfo(userInfo);
        (uint256 tokenId,) = userInfoImpl.getUserInfo(msg.sender);
        require(tokenId > 0, "not lucky");
        uint256 day = block.timestamp.div(1 days);
        (,uint256 quality,,) = IDefxNFTFactory(userInfoImpl.nftFactory()).getNFT(tokenId);
        bonusAmount = getFixedNum(quality) + (_computerSeed() % STEP_SIZE) * 10**18;
        bonusAmounts[msg.sender] = bonusAmounts[msg.sender].add(bonusAmount);
        console.log("Sender bonusAmount is %s, sender is %s, day is %s", bonusAmount, msg.sender, day);
        emit ExcuteLucky(msg.sender, tokenId, bonusAmount);
    }   

    function _computerSeed() private view returns (uint256) {
       uint256 seed = uint256(keccak256(abi.encodePacked(
            (block.timestamp).add
            (block.difficulty).add
            ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (block.timestamp)).add
            (block.gaslimit).add
            ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (block.timestamp)).add
            (block.number)
        )));
        return seed;
    }

    function getFixedNum(uint256 quality) private pure returns(uint256 num){
        num = 10 * 10**18 + quality * STEP_SIZE * 10**18;
    }

    function checkin() public {
        uint256 day = block.timestamp.div(1 days);
        require(checkins[msg.sender][day] == 0, "");
        uint256 bonusAmount = 0;
        uint256 checkinCount = checkins[msg.sender][day - 1].add(1);
        if(checkinCount <= FIXED_AMOUNT_OF_CHECKINS) {
            bonusAmount = CHECKIN_BONUS_FIXED_AMOUNT;
        } else if(checkinCount <= FIXED_AMOUNT_OF_CHECKINS.mul(2)) {
            bonusAmount =  checkinCount.sub(FIXED_AMOUNT_OF_CHECKINS).mul(CHECKIN_BONUS_SETUP).add(FIXED_AMOUNT_OF_CHECKINS);
        } else {
           bonusAmount =  FIXED_AMOUNT_OF_CHECKINS.add(1).mul(CHECKIN_BONUS_SETUP).add(FIXED_AMOUNT_OF_CHECKINS);
        }
        checkins[msg.sender][day] = checkinCount;
        bonusAmounts[msg.sender] =  bonusAmounts[msg.sender].add(bonusAmount);
    }

        /**
     * @dev Return round epochs that a user has participated
     */
    function getCheckins(
        address user,
        uint256 day,
        uint256 size
    ) external view returns (uint256[] memory) {
        uint256[] memory values = new uint256[](size);
        for (uint256 i = 0; i < size; i++) {
            values[i] = checkins[user][day.add(i)];
        }
        return values;
    }
}
