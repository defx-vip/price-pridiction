// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import  "@openzeppelin/contracts/access/Ownable.sol";
contract AddressRelation is Ownable {

    mapping(address => UserInfo) public users;
    mapping(address => bool) public operators;

    struct UserInfo {
        address superior;
        address rootUser;
        bool bind;
    }

    modifier isOperator() {
        require(operators[msg.sender], "not operrator");
        _;
    }

    function bind(address user, address superior) external isOperator returns(bool)  {
        UserInfo storage userInfo = users[user];
        require(!userInfo.bind, "user is already bound");
        UserInfo storage superiorInfo = users[superior];
        userInfo.superior = superior;
        userInfo.bind = true;
        if(superiorInfo.rootUser != address(0x0)) {
            userInfo.rootUser = superiorInfo.rootUser;
        } else {
            userInfo.rootUser = superior;
        }
        return true;
    }

    function setOperator(address user, bool allow)external onlyOwner{
        operators[user] = allow;
    }
}