
// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0; 
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../interface/IDefxNFTFactory.sol";

contract FragmentsToken is Ownable,ERC20 {
    
    event MintNFT(uint256 nftId);

    using SafeMath for uint256;
    uint256 constant  UNIT = 10 ** 18;
    address public nftFactory;
    uint256 public  materialSize = 12 * 10**18;
    uint8 private chanceNum = 8;
    mapping(address => uint256) public userLastNft ;
    
    constructor(address _nftFactory) ERC20("FragmentsToken", "DFTFragmentsToken"){
        nftFactory = _nftFactory;
    }

    modifier checkoutAmount(uint256 amount) {
        require(amount %  UNIT == 0, "transfer error: amount is error" );
        _;
    } 

    function approve(address spender, uint256 amount) public virtual override checkoutAmount(amount) returns (bool) {
       return  super.approve(spender, amount);
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override checkoutAmount(amount)  returns (bool) {
       return super.transferFrom(from, to, amount);
    }

     function burn(address account, uint256 amount) public checkoutAmount(amount)  {
         super._burn(account, amount);
     }

    function transfer(address to, uint256 amount) public  virtual override checkoutAmount(amount) returns (bool)  {
        return super.transfer(to, amount);
     }

    function mint(address account, uint256 amount) external onlyOwner checkoutAmount(amount) {
        super._mint(account, amount);
    }

    function mintNFT() public {
        super._burn(msg.sender, materialSize);
        uint256 seed =  computerSeed();
        uint256 res = seed.mod(chanceNum);
        uint256 nftId =  0;
        if(res != 0) {
            nftId = IDefxNFTFactory(nftFactory).doMint(msg.sender, 0, materialSize);
        }
        userLastNft[msg.sender] = nftId;
        emit MintNFT(nftId);
    }

    function batchMintNFT(uint256 num) public {
        for(uint256 i = 0; i < num; i++) 
            mintNFT();
    }

    function userLastNftInfo(address user) public view returns (
            uint256 id,
            uint256 grade,
            uint256 quality,
            uint256 resId,
            address author
        ){
        id = userLastNft[user];
        (grade, quality, resId, author) = IDefxNFTFactory(nftFactory).getNFT(id);
    }

    function computerSeed() internal view returns (uint256) {
        uint256 seed =
        uint256(
            keccak256(
                abi.encodePacked(
                    (block.timestamp)
                    .add(block.difficulty)
                    .add(
                        (
                        uint256(
                            keccak256(abi.encodePacked(block.coinbase))
                        )
                        ) / (block.timestamp)
                    )
                    .add(block.gaslimit)
                    .add(
                        (uint256(keccak256(abi.encodePacked(msg.sender)))) /
                        (block.timestamp)
                    )
                    .add(block.number)
                )
            )
        );
        return seed;
    }

    function setChanceNum(uint8 _chanceNum)public onlyOwner{
        chanceNum = _chanceNum;
    }

    function setMaterialSize(uint256 _materialSize) public onlyOwner{
        materialSize = _materialSize;
    }
}