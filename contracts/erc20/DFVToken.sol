// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0; 
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "../library/DecimalMath.sol";
import "../interface/IAggregator.sol";
import "../interface/IUserRelation.sol";
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