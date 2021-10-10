// File: @openzeppelin/contracts/utils/Context.sol

// SPDX-License-Identifier: MIT

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

// File: contracts/interface/IUserRelation.sol


pragma solidity ^0.8.0;

interface IUserRelation {

    function bindUser(address user, address superior) external returns(bool);

    function getUserInfo(address user) external view returns(address superior, bool isBroker, bool isBind, uint8 rewardRate);

    function getSuperior(address user) external view returns(address superior);

    function getDftTeam() external view returns(address);
}

// File: contracts/utils/UserRelation.sol


pragma solidity ^0.8.0;




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

    function initialize(address _dftToken, address _dftTeam) external initializer{
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
