// File: contracts/interface/IBonusSharePool.sol

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBonusSharePool {

    function deposit(address user) external payable;

    function airDrop(uint256[] memory nfts, address[] calldata users) external;
}

// File: contracts/interface/IDFVToken.sol


pragma solidity >=0.8.0; 

interface IDFVToken {

    function getSuperior(address account) external view returns (address superior);

    function mint(uint256 dftAmount, address superiorAddress) external;

    function mintToUser(uint256 dftAmount, address account, address superiorAddress) external;

    function _dftRatio() external view returns(uint256 dftRatio);
    
    function _dftTeam() external view returns(address team);

    function transfer(address to, uint256 DFVAmount) external returns (bool);

    function balanceOf(address account) external view returns (uint256 dfvAmount);
}

// File: contracts/interface/Routerv2.sol


pragma solidity >=0.8.0; 

interface Routerv2 {

    function getAmountsOut(uint amountIn, address[] memory path) external view returns (uint[] memory amounts);

    function swapETHForExactTokens(uint payableAmount, address[] calldata path, address to, uint deadline)
  external
  payable
  returns (uint[] memory amounts);
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol



pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: contracts/interface/IDefxERC20.sol


pragma solidity ^0.8.0; 

interface IDefxERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);
    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function safeTransferFrom(address from,address to,uint256 value) external;
    function safeTransfer(address to,uint256 value) external;
    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;
}

// File: contracts/interface/IDefxNFTFactory.sol


pragma solidity ^0.8.0;

interface IDefxNFTFactory {

   function doMint(address author, uint256 resId, uint256 amount) external returns (uint256);

   function safeTransferFrom(address from, address to, uint256 tokenId) external;

   function ownerOf(uint256 tokenId) external view  returns (address);

   function getNFT(uint256 tokenId) external view
        returns (
            uint256 grade,
            uint256 quality,
            uint256 resId,
            address author
        );
}

// File: @openzeppelin/contracts/utils/math/SafeMath.sol



pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// File: @openzeppelin/contracts/utils/Context.sol



pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol



pragma solidity ^0.8.0;


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: contracts/prediction/BonusSharePool.sol


pragma solidity ^0.8.0;








contract BonusSharePool is IBonusSharePool,Ownable {

    using SafeMath for uint256;

    event Deposit(address source, address superior, uint256 amount, string coin);

    event ShareToDFV(address source, address superior, uint256 amount);

    event AirDrop(address onwernAddress, address recipient, uint256 nft);

    IDFVToken public dfvToken;

    address public defxToken;

    address public ethToken;

    Routerv2 public routerv2;

    IDefxNFTFactory defxNFTFactory;

    mapping(address => uint256) public superiorShares;  

    address[] public swapTokens;

    uint256 public deadlineTime;
    
    uint256 public shareAmount;

    uint256 public treasuryAmount; //给合约维护者的返佣

    uint256 public TOTAL_RATE = 100; // 100%

    uint256 public dfvRate = 20; // dfv比例

    uint256 public treasuryRate = 80; // 80

    address public defaultSuperior;

    constructor(
        address _dfvToken,
        address _defxToken,
        address _ethToken,
        address _routerv2,
        address _defxNFTFactory,
        uint256 _deadlineTime
    ) {
        dfvToken = IDFVToken(_dfvToken);
        defxToken = _defxToken;
        ethToken = _ethToken;
        routerv2 = Routerv2(_routerv2);
        defxNFTFactory = IDefxNFTFactory(_defxNFTFactory);
        deadlineTime = _deadlineTime;
        swapTokens = new address[](2);
        swapTokens[0] = ethToken ;
        swapTokens[1] = defxToken;
        IDefxERC20(defxToken).approve(_dfvToken, 2**255);
        defaultSuperior = msg.sender;
    }


    function deposit(address source) external payable override {
        if(source == address(0x0)) {
          treasuryAmount = treasuryAmount.add(msg.value);  
          return;  
        } 
        uint256 amount = msg.value.mul(dfvRate).div(TOTAL_RATE);
        uint256 treasury = msg.value.sub(amount);
        treasuryAmount = treasuryAmount.add(treasury);
        address superior =  dfvToken.getSuperior(source);
        if(superior == address(0x0)) {
            superior = defaultSuperior;
        }
        if(amount > 0 ) {
            superiorShares[superior]  = superiorShares[superior].add(amount);
            shareAmount = shareAmount.add(amount);
            emit Deposit(source, superior, amount, "ETH");
        }
    }

    function superiorShare(address user) external view returns(uint256) {
        uint256 amount = superiorShares[user];
        if(amount == 0) {
            return 0;
        }
        uint256[] memory arr  = routerv2.getAmountsOut(amount, swapTokens);
        return arr[1];
    }

    function superiorShareToDFV() external {
       uint256 amount = superiorShares[msg.sender];
       require(amount > 0, "not balance");
       superiorShares[msg.sender] = 0;
       shareAmount = shareAmount.sub(amount);
       uint256[] memory arr  = routerv2.getAmountsOut(amount, swapTokens);
       uint256 amountOut = arr[1].mul(100).div(100); //允许10%差值
       uint[] memory amounts = routerv2.swapETHForExactTokens{value: amount }(amountOut, swapTokens, address(this), block.timestamp.add(deadlineTime)); 
       address superior =  dfvToken.getSuperior(msg.sender);
        if(superior == address(0x0)) {
            superior = dfvToken._dftTeam();
        }
       dfvToken.mintToUser(amounts[1], msg.sender, superior);
       emit ShareToDFV(msg.sender, superior, amounts[1]);   
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
        _safeTransferBNB(msg.sender, currentTreasuryAmount);
    }

    function setDefaultSuperior(address _superior) external  onlyOwner {
        defaultSuperior = _superior;
    }

    

     function _safeTransferBNB(address to, uint256 value) internal {
        (bool success, ) = to.call{gas: 23000, value: value}("");
        require(success, "TransferHelper: BNB_TRANSFER_FAILED");
    }

}
