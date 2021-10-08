// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../library/Governance.sol";
import "./DefxNFT.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

contract DefxNFTFactory is Governance, Initializable{

     using SafeMath for uint256;

     struct DEFXToken {
        uint256 id;
        uint256 grade;
        uint256 quality;
        uint256 amount;
        uint256 createdTime;
        uint256 blockNum;
        uint256 resId;
        address author;
    }

    event NFTReceived(address operator, address from, uint256 tokenId, bytes dat);

    event NFTAdded(
        uint256 indexed id,
        uint256 grade,
        uint256 quality,
        uint256 amount,
        uint256 createdTime,
        uint256 blockNum,
        uint256 resId,
        address author,
        address nftAddress,
        string resUrl
    );

    event NFTTransfer(
        address from,
        address to,
        uint256 indexed id
    );

    uint256 public lastTokenId;

    uint256 public _qualityBase = 10000;

    //NFT的合约
    DefxNFT public nft ;

    // 挖矿的账户
    mapping(address => bool) public _minters;

    //
    mapping(uint256 => DEFXToken) public _aolis;

     /**
     * @param _nft nft地址
     * @param qualityBase 计算NFT等级的参数，默认10000   
     **/
    function initialize(address _nft, uint256 qualityBase) public initializer  {
        _qualityBase = qualityBase;
        nft = DefxNFT(_nft);
       _minters[msg.sender] = true;
       _governance = msg.sender;
    }

    function setNFT(DefxNFT _nft) public onlyGovernance{
        nft = _nft;
    }

    function addMinter(address minter) public onlyGovernance {
        _minters[minter] = true;
    }

    function removeMinter(address minter) public onlyGovernance {
        _minters[minter] = false;
    }

    function doMint(address author, uint256 resId, uint256 amount) public returns (uint256){
        require(_minters[msg.sender]  , "can't mint");
        require(amount > 0, "must stake defx in nft");
        uint256 seed = _computerSeed();
        ++lastTokenId;
        DEFXToken memory defxInfo;
        defxInfo.id = lastTokenId;
        defxInfo.amount = amount;
        defxInfo.author = author;
        defxInfo.blockNum = block.number;
        defxInfo.createdTime = block.timestamp;
        defxInfo.resId = resId;
        defxInfo.quality = seed % _qualityBase;
        defxInfo.grade = getGrade( defxInfo.quality );
        _aolis[lastTokenId] = defxInfo;
        nft.mint(author, lastTokenId);
        emit NFTAdded(
            defxInfo.id,
            defxInfo.grade,
            defxInfo.quality,
            defxInfo.amount,
            defxInfo.createdTime,
            defxInfo.blockNum,
            defxInfo.resId,
            defxInfo.author,
            address(nft),
            nft.tokenURI(defxInfo.id)
        );
        return lastTokenId;
    }

    /**
     * 放弃 NFT Owner权利
     */
    function abandonNFTOwner(address to) public onlyGovernance {
        nft.transferOwnership(to);
    }

    function updateLastTokenId(uint256 tokenId) external onlyGovernance {
        lastTokenId = tokenId; 
    }

    function updateQualityBase(uint256 quality) external onlyGovernance {
        _qualityBase = quality; 
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) public  {
        require(_minters[msg.sender]  , "can't TransferFrom");
        nft.safeTransferFrom(from, to, tokenId, "");
        emit NFTTransfer(from, to, tokenId);
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

    function getGrade(uint256 quality) public view returns (uint256){
        if( quality < _qualityBase.mul(500).div(1000)){
            return 1;
        }else if( _qualityBase.mul(500).div(1000) <= quality && quality <  _qualityBase.mul(800).div(1000)){
            return 2;
        }else if( _qualityBase.mul(800).div(1000) <= quality && quality <  _qualityBase.mul(900).div(1000)){
            return 3;
        }else if( _qualityBase.mul(900).div(1000) <= quality && quality <  _qualityBase.mul(980).div(1000)){
            return 4;
        }else if( _qualityBase.mul(980).div(1000) <= quality && quality <  _qualityBase.mul(998).div(1000)){
            return 5;
        }else{
            return 6;
        }
    }

    function ownerOf(uint256 tokenId) external view virtual  returns (address) {
      return  nft.ownerOf(tokenId);
    }

    function getTokenGrade(uint256 tokenId) external view virtual  returns (uint256) {
      return _aolis[tokenId].grade;
    }

    function getNFT(uint256 tokenId) external view returns (uint256 grade, uint256 quality, uint256 resId, address author, string memory resUrl
        ) {
        DEFXToken memory a = _aolis[tokenId];
        return (a.grade, a.quality, a.resId, a.author, nft.tokenURI(tokenId));
     }  
}