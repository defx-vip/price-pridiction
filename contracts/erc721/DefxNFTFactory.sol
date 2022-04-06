// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../library/Governance.sol";
import "./DefxNFT.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import '../library/Random.sol';
contract DefxNFTFactory is Governance, Initializable, ReentrancyGuard{

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
    event UpgradedEvent(
        uint256 indexed nftId,
        uint256[] materialNftIds,
        uint256 newTokenId
    );

    uint256 public lastTokenId;
    uint256 public _qualityBase = 10000;
    DefxNFT public nft ;
    mapping(address => bool) public _operators;
    mapping(uint256 => DEFXToken) public _aolis;
    mapping(address => uint256) public upgradedLastNfts;
     /**
     * @param _nft nft地址
     * @param qualityBase 计算NFT等级的参数，默认10000   
     **/
    function initialize(address _nft, uint256 qualityBase) public initializer  {
        _qualityBase = qualityBase;
        nft = DefxNFT(_nft);
       _operators[msg.sender] = true;
       _governance = msg.sender;
    }

    function setNFT(DefxNFT _nft) public onlyGovernance{
        nft = _nft;
    }

    function setOperator(address minter, bool allow) public onlyGovernance {
        _operators[minter] = allow;
    }

    function doMint(address author, uint256 quality, uint256 amount) public returns (uint256){
        require(_operators[msg.sender]  , "can't mint");
        require(quality <= 19, "DefxNFTFacotry: quality error ");
        ++lastTokenId;
        DEFXToken memory defxInfo;
        defxInfo.id = lastTokenId;
        defxInfo.amount = amount;
        defxInfo.author = author;
        defxInfo.blockNum = block.number;
        defxInfo.createdTime = block.timestamp;
        defxInfo.quality = quality;
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

    function updateLastTokenId(uint256 tokenId) external onlyGovernance {
        lastTokenId = tokenId; 
    }

    function updateQualityBase(uint256 quality) external onlyGovernance {
        _qualityBase = quality; 
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public  {
        require(_operators[msg.sender], "can't TransferFrom");
        nft.safeTransferFrom(from, to, tokenId, "");
        emit NFTTransfer(from, to, tokenId);
    }


    function getGrade(uint256 quality) public view returns (uint256){
       
        return quality % _qualityBase + 1;
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

    function upgradeNft(uint256 nftId, uint256[] memory materialNftIds) public nonReentrant {
        require(tx.origin == msg.sender, "Cant call from contract");
        require(nft.ownerOf(nftId) == msg.sender, "DefxNFTFactory: upgradeNft not your nft");
        DEFXToken memory data = _aolis[nftId];
        uint256 quality = data.quality.add(1);
        require(quality <= 19, "DefxNFTFactory: upgradeNft quality error");
        require(materialNftIds.length == 5, "DefxNFTFactory: upgradeNft materialNftIds length error");
        for (uint256 i = 0; i < materialNftIds.length; i++) {
            require(nft.ownerOf(materialNftIds[i]) == msg.sender , "DefxNFTFactory: upgradeNft not your nft");
            DEFXToken memory materialData = _aolis[materialNftIds[i]];
            require(materialData.quality == data.quality , "DefxNFTFactory: upgradeNft material quality error");
            nft.burn(materialNftIds[i]);
        }
       uint256 seed = computerSeed();
       uint256 newTokenId = 0;
       if(seed % 4 != 0 ) {
           nft.burn(nftId);
           newTokenId = doMint(msg.sender, quality, 0);
           upgradedLastNfts[msg.sender] = newTokenId;
       } else {
            upgradedLastNfts[msg.sender] = newTokenId;
       }
       emit UpgradedEvent(nftId, materialNftIds, newTokenId);
    }

    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data) public returns (bytes4) {
        //only receive the _nft staff
        if(address(this) != operator) {
            //invalid from nft
            return 0;
        }
        //success
        emit NFTReceived(operator, from, tokenId, data);
        return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
    }

    function computerSeed() internal view returns (uint256) {
        uint256 seed =
        uint256(
            keccak256(
                abi.encodePacked(
                    (block.timestamp)
                    .add(block.difficulty)
                    .add(lastTokenId)
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
}