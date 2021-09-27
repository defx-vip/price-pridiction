// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/access/AccessControl.sol';
import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import "@openzeppelin/contracts/utils/Strings.sol";
import '@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract DefxNFT is ERC721Pausable, AccessControl, Ownable  {

    using Strings for uint256;

    bytes32 public constant UPDATE_TOKEN_URI_ROLE = keccak256('UPDATE_TOKEN_URI_ROLE');

    bytes32 public constant PAUSED_ROLE = keccak256('PAUSED_ROLE');

    string public baseUri= "";

    uint256 private resCount = 12;

    constructor() ERC721('DFT NFT', 'DFT') {
        _setupRole(UPDATE_TOKEN_URI_ROLE, _msgSender());
        _setupRole(PAUSED_ROLE, _msgSender());
    }

    function mint(address to, uint256 tokenId) public onlyOwner {
        _safeMint(to, tokenId);
    }

    function setBaseURI(string memory _baseUri) public onlyOwner{
         baseUri =_baseUri;
    }

    function setResCount(uint256 _resCount) public onlyOwner{
        resCount = _resCount;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

     /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        string memory baseURI = _baseURI();
        tokenId = tokenId % resCount;
        return bytes(baseURI).length > 0
            ? string(abi.encodePacked(baseURI, tokenId.toString()))
            : '';
    }

    /**
     * @dev Base URI for computing {tokenURI}. Empty by default, can be overriden
     * in child contracts.
     */
    function _baseURI() internal override view virtual returns (string memory) {
        return baseUri;
    }   
}
