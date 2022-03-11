 // SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../interface/IUserInfo.sol";
import "../interface/IDefxNFTFactory.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract UserBonus {
    using SafeMath for uint256;
    event ExcuteLucky(address user, uint256 tokenId, uint256 bonusAmount);
    event Checkin(address user,uint256 bonusAmount);

    struct CheckinRecord {
        uint256 checkinCount;
        uint256 bonusAmount;
    }
    uint256 constant STEP_SIZE = 5 ;
    uint256 constant CHECKIN_LEVEL1_COUNT = 1;
    uint256 constant CHECKIN_BONUS_MULTIPLIER_BET = 10;
    uint256 constant CHECKIN_LEVEL1_AMOUNT = 10 * 10**18;
    uint256 constant CHECKIN_LEVEL_SETUP_AMOUNT =  10**18;
    address public userInfo;
    address public token;
    mapping(address => uint256) public betAmounts;
    mapping(address => uint256) public bonusAmounts;
    mapping(address => bool) public allownUpdateBets;
    mapping(address => mapping(uint256 => CheckinRecord))  public checkins;
    mapping(address => mapping(uint256 => uint256))  public lotterys;
    
    constructor(address _userInfo, address _token) {
        userInfo = _userInfo;
        token = _token;
        allownUpdateBets[msg.sender] = true;
    }

    modifier onlyUpdateBetUser() {
        require(allownUpdateBets[msg.sender], "allownUpdateBets: wut?");
        _;
    }

    function betting(address user, uint256 amount ) public onlyUpdateBetUser {
        betAmounts[user] = betAmounts[user].add(amount);
    }

    // function addBonus(address user, uint256 amount) public onlyUpdateBetUser {
    //     bonusAmounts[user] = bonusAmounts[user].add(amount);
    // }

    function withdrawBonus(uint256 amount) public {
        require(amount <= betAmounts[msg.sender].div(CHECKIN_BONUS_MULTIPLIER_BET), "error amount");
        require(amount <= bonusAmounts[msg.sender], "error amount");
        bonusAmounts[msg.sender] = bonusAmounts[msg.sender].sub(amount);
        betAmounts[msg.sender] = betAmounts[msg.sender].sub(amount.mul(CHECKIN_BONUS_MULTIPLIER_BET));
        IERC20(token).transfer(msg.sender, amount);
    }

    function excuteLucky() public returns (uint256 bonusAmount) {
        IUserInfo userInfoImpl = IUserInfo(userInfo);
        (uint256 tokenId,) = userInfoImpl.getUserInfo(msg.sender);
        require(tokenId > 0, "not lucky");
        uint256 day = block.timestamp.div(1 days);
        //require(!lotterys[msg.sender][day], "excuteLucky error");
        (,uint256 quality,,) = IDefxNFTFactory(userInfoImpl.nftFactory()).getNFT(tokenId);
        bonusAmount = getFixedNum(quality) + (_computerSeed() % STEP_SIZE) * 10**18;
        bonusAmounts[msg.sender] = bonusAmounts[msg.sender].add(bonusAmount);
        lotterys[msg.sender][day] = bonusAmount;
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

    function checkin() public returns (uint256 bonusAmount){
        uint256 day = block.timestamp.div(1 days);
        //require(checkins[msg.sender][day] == 0, "");
        uint256 checkinCount = checkins[msg.sender][day - 1].checkinCount.add(1);
        if(checkinCount <= CHECKIN_LEVEL1_COUNT) {
            bonusAmount = CHECKIN_LEVEL1_AMOUNT;
        } else if(checkinCount <= CHECKIN_LEVEL1_COUNT.mul(2)) {
            bonusAmount = checkinCount.sub(CHECKIN_LEVEL1_COUNT).mul(CHECKIN_LEVEL_SETUP_AMOUNT).add(CHECKIN_LEVEL1_AMOUNT);
        } else {
           bonusAmount = CHECKIN_LEVEL1_COUNT.add(1).mul(CHECKIN_LEVEL_SETUP_AMOUNT).add(CHECKIN_LEVEL1_AMOUNT);
        }
        checkins[msg.sender][day].checkinCount = checkinCount;
        checkins[msg.sender][day].bonusAmount = bonusAmount;
        bonusAmounts[msg.sender] =  bonusAmounts[msg.sender].add(bonusAmount);
        emit Checkin(msg.sender, bonusAmount);
    }

        /**
     * @dev Return round epochs that a user has participated
     */
    function getCheckins(
        address user,
        uint256 startDay,
        uint256 size
    ) external view returns (uint256[] memory) {
        require(size < 40, "The size value is too large");
        uint256[] memory values = new uint256[](size);
        for (uint256 i = 0; i < size; i++) {
            values[i] = checkins[user][startDay.add(i)].checkinCount;
        }
        return values;
    }

    function setUserInfo(address _userInfo) public {
        userInfo = _userInfo;
    }
}
