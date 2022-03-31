// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import '@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol';
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import '@openzeppelin/contracts/access/Ownable.sol';
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import '../interface/IDefxNFTFactory.sol';
import '../interface/IDefxERC20.sol';
import '../library/Random.sol';
contract MysteryBox is Initializable,Ownable, ReentrancyGuard, ERC721Pausable{
    address public immutable deadAddress = 0x000000000000000000000000000000000000dEaD;
    using SafeMath for uint256;
    using SafeERC20 for IDefxERC20;

    struct BoxFactory {
        string name;
        address nftFactory;
        uint256 limit; //0 unlimit
        uint256 minted;
        address currency;
        uint256 price;
        address author;
        string resPrefix;
        uint256 createdTime;
    }

    struct BoxView {
        uint256 factoryId;
        string name;
        address nftFactory;
        uint256 limit; //0 unlimit
        uint256 minted;
        address author;
    }

    struct NFTOpenBox {
         uint256 nftId;
         uint256 quality;
    }

    event NewBoxFactory(
        uint256 indexed id,
        string name,
        address nftFactory,
        uint256 limit,
        address author,
        address currency,
        uint256 price,
        uint256 createdTime
    );
    event Minted(uint256 indexed id, uint256 indexed factoryId, address to);
    event OpenBox(uint256 indexed id, address indexed nft, uint256 boxId, uint256 tokenId);
    
    string private _baseURIVar;
    uint256 private _boxFactoriesId = 0;
    uint256 private _boxId = 1e3;
    uint256 _seed;
    mapping(uint256 => uint256) private _boxes; // boxId: BoxFactoryId
    mapping(uint256 => NFTOpenBox) private _openBoxes; // boxId: BoxFactoryId
    mapping(uint256 => BoxFactory) private _boxFactories; // factoryId: BoxFactory
    mapping(uint256 => uint256) private _lastTransferBlock;
   

    constructor() ERC721('DFT NFT', 'DFT'){
    }

    function addBoxFactory(
        string memory name_,
        address nftFactory,
        uint256 limit,
        address author,
        address currency,
        uint256 price
    ) public onlyOwner{
        _boxFactoriesId++;

        BoxFactory memory box;
        box.name = name_;
        box.nftFactory = nftFactory;
        box.limit = limit;
        box.author = author;
        box.currency = currency;
        box.price = price;
        box.createdTime = block.timestamp;

        _boxFactories[_boxFactoriesId] = box;

        emit NewBoxFactory(
            _boxFactoriesId,
            name_,
            nftFactory,
            limit,
            author,
            currency,
            price,
            block.timestamp
        );
    }

    function mint(address to, uint256 factoryId, uint256 amount) public onlyOwner {
        BoxFactory storage box = _boxFactories[factoryId];
        require(address(box.nftFactory) != address(0), "box not found");
        
        if(box.limit > 0) {
            require(box.limit.sub(box.minted) >= amount, "Over the limit");
        }
        box.minted = box.minted.add(amount);

        for(uint i = 0; i < amount; i++) {
            _boxId++;
            _mint(to, _boxId);
            _boxes[_boxId] = factoryId;
            emit Minted(_boxId, factoryId, to);
        }
    }

    function burn(uint256 tokenId) public {
        address owner = ERC721.ownerOf(tokenId);
        require(_msgSender() == owner, "caller is not the box owner");
        delete _boxes[tokenId];
        _burn(tokenId);
    }

    function getFactory(uint256 factoryId) public view returns (BoxFactory memory)
    {
        return _boxFactories[factoryId];
    }

    function getBox(uint256 boxId) public view returns (BoxView memory)
    {
        uint256 factoryId = _boxes[boxId];
        BoxFactory memory factory = _boxFactories[factoryId];

        return BoxView({
            factoryId: factoryId,
            name: factory.name,
            nftFactory: factory.nftFactory,
            limit: factory.limit,
            minted: factory.minted,
            author: factory.author
        });
    }
    function getOpenBox(uint256 boxId) public view returns (NFTOpenBox memory box)
    {
        box = _openBoxes[boxId];
    }

    function buy(uint256 factoryId, uint256 amount) public {
        BoxFactory storage box = _boxFactories[factoryId];
        require(address(box.nftFactory) != address(0), "box not found");

        if(box.limit > 0) {
            require(box.limit.sub(box.minted) >= amount, "Over the limit");
        }
        box.minted = box.minted.add(amount);

        uint256 price = box.price.mul(amount);
        IDefxERC20(box.currency).safeTransferFrom(msg.sender, address(this), price);
        IDefxERC20(box.currency).safeTransfer(deadAddress, price);
        for(uint i = 0; i < amount; i++) {
            _boxId++;
            _mint(msg.sender, _boxId);
            _boxes[_boxId] = factoryId;
            emit Minted(_boxId, factoryId, msg.sender);
        }
    }

    function openBox(uint256 boxId) public {
        require(isContract(msg.sender) == false && tx.origin == msg.sender, "Prohibit contract calls");
        require(block.number - _lastTransferBlock[boxId] > 1, "wait");
        _upSeed(boxId);
        uint256 factoryId = _boxes[boxId];
        BoxFactory memory factory = _boxFactories[factoryId];
        burn(boxId);
        uint256 seed = Random.computerSeed().div(_seed);
        uint256 quality = seed % 19;
        uint256 tokenId = IDefxNFTFactory(factory.nftFactory).doMint(msg.sender, seed % 19, 0);
        NFTOpenBox storage box = _openBoxes[boxId];
        box.nftId = tokenId;
        box.quality = quality;
        emit OpenBox(boxId, address(factory.nftFactory), boxId, tokenId);
    }

    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    function setBaseURI(string memory uri) public onlyOwner {
        _baseURIVar = uri;
    }

    function _baseURI() internal view override returns (string memory) {
        return _baseURIVar;
    }

     function _transfer(address from, address to, uint256 tokenId) internal virtual override {
        _lastTransferBlock[tokenId] = block.number;
        _upSeed(uint256(keccak256(abi.encodePacked(from, to, tokenId))));

        super._transfer(from, to, tokenId);
    }

    function _upSeed(uint256 val) internal {
        _seed =  (_seed +  val / block.timestamp);
        if (_seed > 50000) {
            _seed %= 50000;
        }
    }

    function upSeed(uint256 val) public onlyOwner {
        _upSeed(val);
    }
    
    function getSeed() public view onlyOwner returns(uint256) {
        return _seed;
    }


}