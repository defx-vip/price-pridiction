// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0; 
pragma experimental ABIEncoderV2;
import '@openzeppelin/contracts/token/ERC20/IERC20.sol'; 
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import  "@openzeppelin/contracts/access/Ownable.sol";

import "../library/DecimalMath.sol";

contract DefxTokenAggregator is Ownable {
    
    using SafeMath for uint256;

    // ============ Storage ============

    address immutable _DEFX_TOKEN_;
    
    address[] _LOCKED_CONTRACT_ADDRESS_;

    constructor(address defxToken){
        _DEFX_TOKEN_ = defxToken;
    }

    function addLockedContractAddress(address lockedContract) external onlyOwner {
        require(lockedContract != address(0));
        _LOCKED_CONTRACT_ADDRESS_.push(lockedContract);
    }

    function removeLockedContractAddress(address lockedContract) external onlyOwner {
        require(lockedContract != address(0));
        address[] memory lockedContractAddress = _LOCKED_CONTRACT_ADDRESS_;
        for (uint256 i = 0; i < lockedContractAddress.length; i++) {
            if (lockedContractAddress[i] == lockedContract) {
                lockedContractAddress[i] = lockedContractAddress[lockedContractAddress.length - 1];
                break;
            }
        }
        _LOCKED_CONTRACT_ADDRESS_ = lockedContractAddress;
        _LOCKED_CONTRACT_ADDRESS_.pop();
    } 

    function getCirculationSupply() public view returns (uint256 circulation) {
        circulation = 10**9 * 10**18; //
        for (uint256 i = 0; i < _LOCKED_CONTRACT_ADDRESS_.length; i++) {
            circulation -= IERC20(_DEFX_TOKEN_).balanceOf(_LOCKED_CONTRACT_ADDRESS_[i]);
        }
    }
}
