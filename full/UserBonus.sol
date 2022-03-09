// File: contracts/interface/IUserInfo.sol

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0; 

interface IUserInfo {

    function getUserInfo(address user) external view returns(uint256 nftId, string memory nickname);

    function nftFactory() external view returns(address nftFactoryAddress);
}

// File: contracts/interface/IDefxNFTFactory.sol


pragma solidity ^0.8.0;

interface IDefxNFTFactory {

   function doMint(address author, uint256 quality, uint256 amount) external returns (uint256);

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


// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

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
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
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

// File: contracts/bonus/UserBonus.sol


pragma solidity ^0.8.0;





contract UserBonus {
    using SafeMath for uint256;
    event ExcuteLucky(address user, uint256 tokenId, uint256 bonusAmount);
    uint256 constant STEP_SIZE = 5 ;
    uint256 constant FIXED_OF_CHECKINS = 1;
    uint256 constant BONUS_MULTIPLIER_BET = 10;
    uint256 constant CHECKIN_BONUS_FIXED_AMOUNT = 10 * 10**18;
    uint256 constant CHECKIN_BONUS_SETUP =  10**18;
    address public userInfo;
    address public token;
    mapping(address => uint256) public betAmounts;
    mapping(address => uint256) public bonusAmounts;
    mapping(address => bool) public allownUpdateBets;
    mapping(address => mapping(uint256 => uint256))  public checkins;
    mapping(address => mapping(uint256 => bool))  public lotterys;
    
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
        require(!lotterys[msg.sender][day], "excuteLucky error");
        (,uint256 quality,,) = IDefxNFTFactory(userInfoImpl.nftFactory()).getNFT(tokenId);
        bonusAmount = getFixedNum(quality) + (_computerSeed() % STEP_SIZE) * 10**18;
        bonusAmounts[msg.sender] = bonusAmounts[msg.sender].add(bonusAmount);
        lotterys[msg.sender][day] = true;
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
        require(checkins[msg.sender][day] == 0, "");
        uint256 checkinCount = checkins[msg.sender][day - 1].add(1);
        if(checkinCount <= FIXED_OF_CHECKINS) {
            bonusAmount = CHECKIN_BONUS_FIXED_AMOUNT;
        } else if(checkinCount <= FIXED_OF_CHECKINS.mul(2)) {
            bonusAmount = checkinCount.sub(FIXED_OF_CHECKINS).mul(CHECKIN_BONUS_SETUP).add(CHECKIN_BONUS_FIXED_AMOUNT);
        } else {
           bonusAmount = FIXED_OF_CHECKINS.add(1).mul(CHECKIN_BONUS_SETUP).add(CHECKIN_BONUS_FIXED_AMOUNT);
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

    function setUserInfo(address _userInfo) public {
        userInfo = _userInfo;
    }
}
