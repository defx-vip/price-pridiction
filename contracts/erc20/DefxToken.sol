// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0; 
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol';

contract DefxToken is Ownable,ERC20Capped {

    constructor() ERC20("DFT token", "DFT") ERC20Capped(10**9 * 10**18) {
   
    }

    function mint(address account, uint256 amount) external onlyOwner {
        super._mint(account, amount);
    }
   
}