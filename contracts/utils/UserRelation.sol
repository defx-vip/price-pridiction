// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import  "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
contract UserRelation is Ownable,Initializable {

    mapping(address => UserInfo) public users;
    mapping(address => bool) public operators;
    address public dftToken;

    struct UserInfo {
        address superior;
        uint8 role;
        bool bind;
    }

    modifier isOperator() {
        require(operators[msg.sender], "UserRelation: not operrator");
        _;
    }

    function initialize(address _dftToken) external initializer{
        dftToken = _dftToken;
    }

    function bindUser(address user, address superior) external isOperator returns(bool)  {
        UserInfo storage userInfo = users[user];
        require(!userInfo.bind, "UserRelation: user is already bound");
        userInfo.superior = superior;
        userInfo.bind = true;
        //userInfo.superior2 = superiorInfo.superior;
        return true;
    }

    function bindToBroker(address superior) external returns(bool)  {
        UserInfo storage userInfo = users[msg.sender];
        UserInfo storage superiorInfo = users[superior];
        UserInfo storage superiorInfo1 = users[superiorInfo.superior];
        require(superiorInfo.role == 1 || superiorInfo1.role == 1, "UserRelation: superior not broker");
        require(!userInfo.bind, "UserRelation: user is already bound");
        userInfo.superior = superior;
        if(superiorInfo.role == 1) {
            userInfo.role = 2;
        }
        if(superiorInfo1.role == 1) {
            userInfo.role = 3;
        }
        userInfo.bind = true;
        return true;
    }

    function toBroker() external returns(bool) {
        UserInfo storage userInfo = users[msg.sender];
        require(!userInfo.bind,  "UserRelation: invalid  user address");
        require(IERC20(dftToken).transferFrom(msg.sender, address(this), 1000 * 10 ** 18), "transferFrom error");
        userInfo.role = 1;
        userInfo.bind = true;
        return true;
    }

    function quitBroker() external returns(bool) {
        UserInfo storage userInfo = users[msg.sender];
        require(userInfo.bind && userInfo.role == 1,  "UserRelation: invalid  user address");
        require(IERC20(dftToken).transfer(msg.sender, 1000 * 10 ** 18), "transferFrom error");
        userInfo.role = 0;
        userInfo.bind = false;
        return true;
    }

    function getUserInfo(address user) external view returns(address superior, uint8 role, bool isBind) {
        UserInfo memory userInfo = users[user];
        superior  = userInfo.superior;
        role  = userInfo.role;
        isBind =  userInfo.bind;
    }

    function getSuperior(address user) external view returns(address superior) {
        superior = users[user].superior;
    }

    
    function setOperator(address user, bool allow)external onlyOwner{
        operators[user] = allow;
    }

}