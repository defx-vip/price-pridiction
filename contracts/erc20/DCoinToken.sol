// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0; 
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol';
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract DCoinToken is Ownable,ERC20Capped {
     
    address public immutable deadAddress = 0x000000000000000000000000000000000000dEaD;
    uint256 public immutable transferFeeRate = 5;
     using SafeMath for uint256;

     mapping (address => bool) private _isExcludedFromFee;


    constructor() ERC20("DCoin Token", "DCoin") ERC20Capped(150 * 10**9 * 10**18) {
   
    }

    function mint(address account, uint256 amount) external onlyOwner {
        super._mint(account, amount);
    }

    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }
    
    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }
    
    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

     function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual override{
       if(_isExcludedFromFee[sender] || _isExcludedFromFee[recipient] ) {
            ERC20._transfer(sender, recipient, amount);
       } else {
            uint256 fee = amount.mul(transferFeeRate).div(100);
            ERC20._transfer(sender, deadAddress, fee);
            ERC20._transfer(sender, recipient, amount.sub(fee));
         
       }
    }

   
}