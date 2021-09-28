// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

// SPDX-License-Identifier: MIT

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

// File: @openzeppelin/contracts/utils/Address.sol



pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// File: @openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol



pragma solidity ^0.8.0;



/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
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

// File: @openzeppelin/contracts/proxy/utils/Initializable.sol



pragma solidity ^0.8.0;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}

// File: contracts/library/DecimalMath.sol



pragma solidity >=0.6.12;
pragma experimental ABIEncoderV2;


library MySafeMath {
    using SafeMath for uint256;

    function divCeil(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 quotient = a.div(b);
        uint256 remainder = a - quotient * b;
        if (remainder > 0) {
            return quotient + 1;
        } else {
            return quotient;
        }
    }
}

library DecimalMath {
    using SafeMath for uint256;

    uint256 internal constant ONE = 10**18;
    uint256 internal constant ONE2 = 10**36;

    function mulFloor(uint256 target, uint256 d) internal pure returns (uint256) {
        return target.mul(d) / (10**18);
    }

    function mulCeil(uint256 target, uint256 d) internal pure returns (uint256) {
        return MySafeMath.divCeil(target.mul(d), 10**18);
    }

    function divFloor(uint256 target, uint256 d) internal pure returns (uint256) {
        return target.mul(10**18).div(d);
    }

    function divCeil(uint256 target, uint256 d) internal pure returns (uint256) {
        return MySafeMath.divCeil(target.mul(10**18), d);
    }

    function reciprocalFloor(uint256 target) internal pure returns (uint256) {
        return uint256(10**36).div(target);
    }

    function reciprocalCeil(uint256 target) internal pure returns (uint256) {
        return MySafeMath.divCeil(uint256(10**36), target);
    }
}

// File: contracts/interface/IAggregator.sol


pragma solidity ^0.8.0;

//ERC20Capped
interface IAggregator {
    function getCirculationSupply() external view returns (uint256);
}

// File: contracts/interface/IUserRelation.sol


pragma solidity ^0.8.0;

interface IUserRelation {

    function bindUser(address user, address superior) external returns(bool);

    function getUserInfo(address user) external view returns(address superior, bool isBroker, bool isBind, uint8 rewardRate);

    function getSuperior(address user) external view returns(address superior);

    function getDftTeam() external view returns(address);
}

// File: contracts/erc20/DFVToken.sol



pragma solidity >=0.8.0; 
pragma experimental ABIEncoderV2;








contract DFVToken is Ownable,Initializable {
    
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // ============ Storage(ERC20) ============

    string public name = "DFV Membership Token";
    string public symbol = "DFV";
    uint8 public decimals = 18;
    
    uint128 public MAX_UINT112 = ~uint112(0);

    uint256 public _MIN_PENALTY_RATIO_ = 10 * 10**16; // 10%
    uint256 public _MAX_PENALTY_RATIO_ = 30 * 10**16; // 30%

    mapping(address => mapping(address => uint256)) internal _allowed;

    // ============ Storage ============

    address public  _dftToken;
    address public _aggregator;

    bool public _canTransfer;

    // staking reward parameters
    uint256 public _dftPerBlock;
    uint256 public constant _superiorRatio = 10**17; // 0.1
    uint256 public constant _dftRatio = 100; // 100
    uint256 public _dftFeeBurnRatio;

    // accounting
    uint112 public alpha = 10**18; // 1
    uint112 public _totalBlockDistribution;
    uint32 public _lastRewardBlock;

    uint256 public _totalBlockReward;
    uint256 public _totalStakingPower;
    mapping(address => UserInfo) public userInfo;

    address public _userRelation;
    address public operatorAddress;
    

    struct UserInfo {
        uint128 stakingPower;
        uint128 superiorSP;
        uint256 credit;
    }

    // ============ Events ============

    event MintDFV(address user, address superior, uint256 mintDFT);
    event RedeemDFV(address user, uint256 receiveDFT, uint256 burnDFT, uint256 feeDFT);
    event DonateDFT(address user, uint256 donateDFT);
    event SetCanTransfer(bool allowed);

    event PreDeposit(uint256 dftAmount);
    event ChangePerReward(uint256 dftPerBlock);
    event UpdateDFTFeeBurnRatio(uint256 dftFeeBurnRatio);

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);

    // ============ Modifiers ============

    modifier canTransfer() {
        require(_canTransfer, "DFVToken: not allowed transfer");
        _;
    }

    modifier balanceEnough(address account, uint256 amount) {
        require(availableBalanceOf(account) >= amount, "DFVToken: available amount not enough");
        _;
    }

    modifier onlyOperator() {
        require(msg.sender == operatorAddress, "operator: wut?");
        _;
    }
    // ============ Constructor ============

    function initialize(
        address aggregator,
        address dftToken,
        address userRelation
    )  public initializer {
        _aggregator = aggregator;
        _dftToken = dftToken;
        _userRelation = userRelation;
    }

    // ============ Ownable Functions ============`

    function setCanTransfer(bool allowed) public onlyOwner {
        _canTransfer = allowed;
        emit SetCanTransfer(allowed);
    }

    function changePerReward(uint256 dftPerBlock) public onlyOwner {
        _updateAlpha();
        _dftPerBlock = dftPerBlock;
        emit ChangePerReward(dftPerBlock);
    }

    function updateDFTFeeBurnRatio(uint256 dftFeeBurnRatio) public onlyOwner {
        _dftFeeBurnRatio = dftFeeBurnRatio;
        emit UpdateDFTFeeBurnRatio(_dftFeeBurnRatio);
    }

    function updateAggregator(address aggregator) public onlyOwner {
        _aggregator = aggregator;
    }

    function emergencyWithdraw() public onlyOwner {
        uint256 dftBalance = IERC20(_dftToken).balanceOf(address(this));
        IERC20(_dftToken).transfer(owner(), dftBalance);
    }

    // ============ Mint & Redeem & Donate ============
    function mintToUser(uint256 dftAmount, address to) external onlyOperator {
        require(dftAmount > 0, "DFVToken: must mint greater than 0");
        UserInfo storage user = userInfo[to];
        address superior = IUserRelation(_userRelation).getSuperior(to);
        require(
            superior != address(0) && superior != to,
            "DFVToken: Superior INVALID"
        );
        _updateAlpha();
        IERC20(_dftToken).safeTransferFrom(msg.sender, address(this), dftAmount);
        uint256 newStakingPower = DecimalMath.divFloor(dftAmount, alpha);
        _mint(user, superior, newStakingPower);
        emit MintDFV(to, superior, dftAmount);
    }

    function mint(uint256 dftAmount, address superiorAddress) public {
        require(
            superiorAddress != address(0) && superiorAddress != msg.sender,
            "DFVToken: Superior INVALID"
        );
        require(dftAmount > 0, "DFVToken: must mint greater than 0");

        UserInfo storage user = userInfo[msg.sender];
        address superior = IUserRelation(_userRelation).getSuperior(msg.sender);
        if (superior == address(0)) {
            superior = IUserRelation(_userRelation).getSuperior(superiorAddress);
            address _dftTeam = IUserRelation(_userRelation).getDftTeam();
            require(
                superiorAddress == _dftTeam || 
                (superior != address(0) && balanceOf(superiorAddress) >= 1),
                "DFVToken: INVALID_SUPERIOR_ADDRESS"
            );
            IUserRelation(_userRelation).bindUser(msg.sender, superiorAddress);
            superior = superiorAddress;
        }
        
        _updateAlpha();
      
        IERC20(_dftToken).safeTransferFrom(msg.sender, address(this), dftAmount);
        
        uint256 newStakingPower = DecimalMath.divFloor(dftAmount, alpha);
        _mint(user, superior, newStakingPower);

        emit MintDFV(msg.sender, superior, dftAmount);
    }

    function redeem(uint256 DFVAmount, bool all) public balanceEnough(msg.sender, DFVAmount) {
        _updateAlpha();
        UserInfo storage user = userInfo[msg.sender];

        uint256 dftAmount;
        uint256 stakingPower;

        if (all) {
            stakingPower = uint256(user.stakingPower).sub(DecimalMath.divFloor(user.credit, alpha));
            dftAmount = DecimalMath.mulFloor(stakingPower, alpha);
        } else {
            dftAmount = DFVAmount.mul(_dftRatio);
            stakingPower = DecimalMath.divFloor(dftAmount, alpha);
        }
        address superior = IUserRelation(_userRelation).getSuperior(msg.sender);
        _redeem(user, superior, stakingPower);

        (uint256 dftReceive, uint256 burnDftAmount, uint256 withdrawFeeAmount) = getWithdrawResult(dftAmount);

        IERC20(_dftToken).transfer(msg.sender, dftReceive);

        if (burnDftAmount > 0) {
            IERC20(_dftToken).transfer(address(0), burnDftAmount);
        }

        if (withdrawFeeAmount > 0) {
            alpha = uint112(
                uint256(alpha).add(
                    DecimalMath.divFloor(withdrawFeeAmount, _totalStakingPower)
                )
            );
        }
        emit RedeemDFV(msg.sender, dftReceive, burnDftAmount, withdrawFeeAmount);
    }

    function donate(uint256 dftAmount) public {

        IERC20(_dftToken).safeTransferFrom(msg.sender, address(this), dftAmount);

        alpha = uint112(
            uint256(alpha).add(DecimalMath.divFloor(dftAmount, _totalStakingPower))
        );
        emit DonateDFT(msg.sender, dftAmount);
    }

    function preDepositedBlockReward(uint256 dftAmount) public {

        IERC20(_dftToken).safeTransferFrom(msg.sender, address(this), dftAmount);

        _totalBlockReward = _totalBlockReward.add(dftAmount);
        emit PreDeposit(dftAmount);
    }

    // ============ ERC20 Functions ============

    function totalSupply() public view returns (uint256 dfvSupply) {
        uint256 totalDft = IERC20(_dftToken).balanceOf(address(this));
        (,uint256 curDistribution) = getLatestAlpha();
        uint256 actualDft = totalDft.sub(_totalBlockReward.sub(curDistribution.add(_totalBlockDistribution)));
        dfvSupply = actualDft / _dftRatio;
    }

    function balanceOf(address account) public view returns (uint256 dfvAmount) {
        dfvAmount = dftBalanceOf(account) / _dftRatio;
    }

    function transfer(address to, uint256 DFVAmount) public returns (bool) {
        _updateAlpha();
        _transfer(msg.sender, to, DFVAmount);
        return true;
    }

    function approve(address spender, uint256 DFVAmount) canTransfer public returns (bool) {
        _allowed[msg.sender][spender] = DFVAmount;
        emit Approval(msg.sender, spender, DFVAmount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 DFVAmount
    ) public returns (bool) {
        require(DFVAmount <= _allowed[from][msg.sender], "ALLOWANCE_NOT_ENOUGH");
        _updateAlpha();
        _transfer(from, to, DFVAmount);
        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(DFVAmount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowed[owner][spender];
    }

    // ============ Helper Functions ============

    function getLatestAlpha() public view returns (uint256 newAlpha, uint256 curDistribution) {
        if (_lastRewardBlock == 0) {
            curDistribution = 0;
        } else {
            curDistribution = _dftPerBlock * (block.number - _lastRewardBlock);
        }
        if (_totalStakingPower > 0) {
            newAlpha = uint256(alpha).add(DecimalMath.divFloor(curDistribution, _totalStakingPower));
        } else {
            newAlpha = alpha;
        }
    }

    function availableBalanceOf(address account) public view returns (uint256 DFVAmount) {
        DFVAmount = balanceOf(account);
    }

    function dftBalanceOf(address account) public view returns (uint256 dftAmount) {
        UserInfo memory user = userInfo[account];
        (uint256 newAlpha,) = getLatestAlpha();
        uint256 nominalDft =  DecimalMath.mulFloor(uint256(user.stakingPower), newAlpha);
        if(nominalDft > user.credit) {
            dftAmount = nominalDft - user.credit;
        } else {
            dftAmount = 0;
        }
    }

    function getWithdrawResult(uint256 dftAmount)
    public
    view
    returns (
        uint256 dftReceive,
        uint256 burnDftAmount,
        uint256 withdrawFeeDftAmount
    )
    {
        uint256 feeRatio = getDftWithdrawFeeRatio();

        withdrawFeeDftAmount = DecimalMath.mulFloor(dftAmount, feeRatio);
        dftReceive = dftAmount.sub(withdrawFeeDftAmount);

        burnDftAmount = DecimalMath.mulFloor(withdrawFeeDftAmount, _dftFeeBurnRatio);
        withdrawFeeDftAmount = withdrawFeeDftAmount.sub(burnDftAmount);
    }

    function getDftWithdrawFeeRatio() public view returns (uint256 feeRatio) {
        uint256 dftCirculationAmount = IAggregator(_aggregator).getCirculationSupply();

        uint256 x =
        DecimalMath.divCeil(
            IERC20(_dftToken).totalSupply() * 100,
            dftCirculationAmount
        );

        feeRatio = getRatioValue(x);
    }

    function getRatioValue(uint256 input) public view returns (uint256) {

        // y = 30% (x < 0.1)
        // y = 10% (x > 0.5)
        // y = 0.34 - 0.4 * x

        if (input < 10**17) {
            return _MAX_PENALTY_RATIO_;
        } else if (input > 5 * 10**17) {
            return _MIN_PENALTY_RATIO_;
        } else {
            return 300 * 10**15 - DecimalMath.mulFloor(input, 40 * 10**16);
        }
    }

    function getSuperior(address account) public view returns (address superior) {
        return IUserRelation(_userRelation).getSuperior(account);
    }

    // ============ Internal Functions ============
  
    function _updateAlpha() internal {
        (uint256 newAlpha, uint256 curDistribution) = getLatestAlpha();
        uint256 newTotalDistribution = curDistribution.add(_totalBlockDistribution);
        require(newAlpha <= MAX_UINT112 && newTotalDistribution <= MAX_UINT112, "OVERFLOW");
        alpha = uint112(newAlpha);
        _totalBlockDistribution = uint112(newTotalDistribution);
        _lastRewardBlock = uint32(block.number);
    }

    function _mint(UserInfo storage to, address superiorAddress, uint256 stakingPower) internal {
        require(stakingPower < MAX_UINT112, "OVERFLOW");
        UserInfo storage superior = userInfo[superiorAddress];
        uint256 superiorIncreSP = DecimalMath.mulFloor(stakingPower, _superiorRatio);
        uint256 superiorIncreCredit = DecimalMath.mulFloor(superiorIncreSP, alpha);

        to.stakingPower = uint128(uint256(to.stakingPower).add(stakingPower));
        to.superiorSP = uint128(uint256(to.superiorSP).add(superiorIncreSP));

        superior.stakingPower = uint128(uint256(superior.stakingPower).add(superiorIncreSP));
        superior.credit = uint128(uint256(superior.credit).add(superiorIncreCredit));

        _totalStakingPower = _totalStakingPower.add(stakingPower).add(superiorIncreSP);
    }

    function _redeem(UserInfo storage from, address superiorAddress,uint256 stakingPower) internal {
        from.stakingPower = uint128(uint256(from.stakingPower).sub(stakingPower));

        // superior decrease sp = min(stakingPower*0.1, from.superiorSP)
        uint256 superiorDecreSP = DecimalMath.mulFloor(stakingPower, _superiorRatio);
        superiorDecreSP = from.superiorSP <= superiorDecreSP ? from.superiorSP : superiorDecreSP;
        from.superiorSP = uint128(uint256(from.superiorSP).sub(superiorDecreSP));

        UserInfo storage superior = userInfo[superiorAddress];
        uint256 creditSP = DecimalMath.divFloor(superior.credit, alpha);

        if (superiorDecreSP >= creditSP) {
            superior.credit = 0;
            superior.stakingPower = uint128(uint256(superior.stakingPower).sub(creditSP));
        } else {
            superior.credit = uint128(
                uint256(superior.credit).sub(DecimalMath.mulFloor(superiorDecreSP, alpha))
            );
            superior.stakingPower = uint128(uint256(superior.stakingPower).sub(superiorDecreSP));
        }

        _totalStakingPower = _totalStakingPower.sub(stakingPower).sub(superiorDecreSP);
    }

    function _transfer(
        address from,
        address to,
        uint256 DFVAmount
    ) internal canTransfer balanceEnough(from, DFVAmount) {
        require(from != address(0), "transfer from the zero address");
        require(to != address(0), "transfer to the zero address");
        require(from != to, "transfer from same with to");

        uint256 stakingPower = DecimalMath.divFloor(DFVAmount * _dftRatio, alpha);

        UserInfo storage fromUser = userInfo[from];
        UserInfo storage toUser = userInfo[to];

        _redeem(fromUser, IUserRelation(_userRelation).getSuperior(from), stakingPower);
        _mint(toUser, IUserRelation(_userRelation).getSuperior(to), stakingPower);

        emit Transfer(from, to, DFVAmount);
    }

    function setOperatorAddress(address _operatorAddress) external  onlyOwner {
        operatorAddress = _operatorAddress;
    }

    function getUserInfo(address userAddress)external view returns(
        uint128 stakingPower,
        uint128 superiorSP,
        uint256 credit,
        address superior
    ) {
        UserInfo memory user = userInfo[userAddress];
        stakingPower = user.stakingPower;
        superiorSP = user.superiorSP;
        credit = user.credit;
        superior = IUserRelation(_userRelation).getSuperior(userAddress);
    }
}
