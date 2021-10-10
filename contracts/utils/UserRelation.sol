// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import  "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "../interface/IUserRelation.sol";
contract UserRelation is Ownable,Initializable,IUserRelation {

    mapping(address => UserInfo) public users;
    mapping(address => bool) public operators;
    address public dftToken;
    address public dftTeam;
    uint8 public defaultRewardRate;

    struct UserInfo {
        address superior;
        bool bind;
        bool isBroker;
        uint8 rewardRate;
    }

    event BindToBroker(address account, address superior);

    event BindUser(address account, address superior);

    event ToBroker(address account);

    event QuitBroker(address account);

    event ChanageRewardRate(address account, uint8 rate);

    modifier isOperator() {
        require(operators[msg.sender], "UserRelation: not operrator");
        _;
    }

    constructor(address _dftToken, address _dftTeam){
        dftTeam = _dftTeam;
        dftToken = _dftToken;
        defaultRewardRate = 20;
    }

    function bindUser(address user, address superior) external  isOperator override returns(bool)  {
        UserInfo storage userInfo = users[user];
        require(!userInfo.bind, "UserRelation: user is already bound");
        userInfo.superior = superior;
        userInfo.bind = true;
        userInfo.rewardRate = defaultRewardRate;
        emit BindUser(user, superior);
        return true;
    }

    function bindToBroker(address superior) external  returns(bool)  {
        UserInfo storage userInfo = users[msg.sender];
        require(!userInfo.bind, "UserRelation: user is already bound");
        UserInfo storage superiorInfo = users[superior];
        UserInfo storage superiorInfo1 = users[superiorInfo.superior];
        require(superiorInfo.isBroker || superiorInfo1.isBroker, "UserRelation: superior not broker");
        userInfo.superior = superior;
        userInfo.rewardRate = defaultRewardRate;
        userInfo.bind = true;
        emit BindToBroker(msg.sender, superior);
        return true;
    }

    function toBroker() external returns(bool) {
        UserInfo storage userInfo = users[msg.sender];
        require(
         !userInfo.isBroker && (userInfo.superior == address(0x0) || userInfo.superior == dftTeam), 
         "UserRelation: invalid  user address"
         );
        require(IERC20(dftToken).transferFrom(msg.sender, address(this), 1000 * 10 ** 18), "transferFrom error");
        userInfo.isBroker = true;
        userInfo.bind = true;
        userInfo.superior = dftTeam;
        userInfo.rewardRate = defaultRewardRate;
        emit ToBroker(msg.sender);
        return true;
    }

    function quitBroker() external returns(bool) {
        UserInfo storage userInfo = users[msg.sender];
        require(userInfo.isBroker,  "UserRelation: invalid  user address");
        require(IERC20(dftToken).transfer(msg.sender, 10000 * 10 ** 18), "transferFrom error");
        userInfo.isBroker = false;
        emit QuitBroker(msg.sender);
        return true;
    }

    function setSubUserRewardRate(address user, uint8 rewardRate) external returns(bool) {
        require( rewardRate <= 100 ,"UserRelation: invalid rewardRate");
        require(users[user].superior == msg.sender, "UserRelation: invalid  user address" );
        UserInfo storage userInfo = users[user];
        userInfo.rewardRate = rewardRate;
        emit ChanageRewardRate(user, rewardRate);
        return true;
    }

    function getUserInfo(address user) external override view returns(address superior, bool isBroker, bool isBind, uint8 rewardRate) {
        UserInfo memory userInfo = users[user];
        superior  = userInfo.superior;
        isBroker  = userInfo.isBroker;
        isBind =  userInfo.bind;
        rewardRate = userInfo.rewardRate;
    }

    function getSuperior(address user) external override view returns(address superior) {
        superior = users[user].superior;
    }

    function setOperator(address user, bool allow)external onlyOwner{
        operators[user] = allow;
    }

    function setDefaultRewardRate(uint8 _defaultRewardRate)external  onlyOwner{
        defaultRewardRate = _defaultRewardRate;
    }

    function getBrokerRole(address user) external view returns(uint8 role) {
        UserInfo memory userInfo = users[user];
        if(userInfo.isBroker) {
           role = 1;
        } else if(users[userInfo.superior].isBroker){
           role = 2;
        }
    }

    function getDftTeam() external view override returns(address) {
        return dftTeam;
    }
}