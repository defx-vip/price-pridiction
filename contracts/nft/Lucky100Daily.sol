// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./UserInfo.sol";
import "hardhat/console.sol";
import "../interface/IDefxNFTFactory.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
/**
 * Daily draw
 */
contract Lucky100Daily {
    using SafeMath for uint256;

    event ExcuteLucky(address user, uint256 tokenId, uint256 bonusAmount);

    uint256 constant STEP_SIZE = 5 ;
    address public userInfo;
    address public token;
    //time => user_address => bonusAmount
    mapping(uint256 => mapping (address => uint256)) public result;

    constructor(address _userInfo, address _token) {
        userInfo = _userInfo;
        token = _token;
    }

    function excute() public returns (uint256 bonusAmount) {
        UserInfo userInfoImpl = UserInfo(userInfo);
        (uint256 tokenId,) = userInfoImpl.getUserInfo(msg.sender);
        require(tokenId > 0, "not lucky");
        uint256 day = block.timestamp.div(1 days);
        (,uint256 quality,,) = IDefxNFTFactory(userInfoImpl.nftFactory()).getNFT(tokenId);
        bonusAmount = getFixedNum(quality) + (_computerSeed() % STEP_SIZE) * 10**18;
        IERC20(token).transfer(msg.sender, bonusAmount);
        result[day][msg.sender] = bonusAmount;
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
}