// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "./IERC4906.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "operator-filter-registry/src/DefaultOperatorFilterer.sol";

//=====================================================================
// custom error
//=====================================================================
library NFTErrors {
    error NoneMinted();
    error NotMinter();
}

contract SampleNFT is DefaultOperatorFilterer, Ownable, ERC721A, ERC2981, IERC4906 {
    //=====================================================================
    // storage
    //=====================================================================
    address public minter;
    uint96 public defaultRoyalty = 500; // 5.0%
    string public baseURI;
    string public suffix = ".json";

    //=====================================================================
    // modifier
    //=====================================================================
    modifier onlyMinter() {
        if (msg.sender != minter) revert NFTErrors.NotMinter();
        _;
    }

    //=====================================================================
    // constructor
    //=====================================================================
    constructor(string memory _baseURI, address _royalityReceiver) ERC721A("SampleNFT", "SNFT") {
        baseURI = _baseURI;
        _setDefaultRoyalty(_royalityReceiver, defaultRoyalty);
    }

    //=====================================================================
    // [external/onlyOperator] mint
    //=====================================================================
    function mint(address _to, uint256 _quantity) external onlyMinter {
        _safeMint(_to, _quantity);
    }

    //=====================================================================
    // [external] ownerMint
    //=====================================================================
    function ownerMint(address _to, uint256 _quantity) external onlyOwner {
        _safeMint(_to, _quantity);
    }

    //=====================================================================
    // [external/onlyOwner] set
    //=====================================================================
    function setMinter(address _minter) external onlyOwner {
        minter = _minter;
    }

    function setBaseURI(string memory _baseURI) external onlyOwner {
        baseURI = _baseURI;
        
        if (totalSupply() == 0) revert NFTErrors.NoneMinted();
        emit BatchMetadataUpdate(1, type(uint256).max);
    }

    //=====================================================================
    // tokenURI
    //=====================================================================
    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        if (!_exists(tokenId)) revert();

        string memory baseURI = _baseURI();
        return bytes(baseURI).length != 0 ? string(abi.encodePacked(baseURI, _toString(tokenId), suffix)) : '';
    }

    //=====================================================================
    // [external/onlyOwner] for ERC2981
    //=====================================================================
    function setRoyaltyInfo(address _receiver, uint96 _feeNumerator) external onlyOwner {
        _setDefaultRoyalty(_receiver, _feeNumerator);
    }

    //=====================================================================
    // [internal] for ERC721A
    //=====================================================================
    function _startTokenId() internal view override returns (uint256) {
        return 1;
    }

    //=====================================================================
    // [public/override/onlyAllowedOperatorApproval] for OpetatorFilter
    //=====================================================================
    function setApprovalForAll(address operator, bool approved) public override onlyAllowedOperatorApproval(operator) {
        super.setApprovalForAll(operator, approved);
    }

    function approve(address operator, uint256 tokenId) public payable override onlyAllowedOperatorApproval(operator) {
        super.approve(operator, tokenId);
    }

    function transferFrom(address from, address to, uint256 tokenId) public payable override onlyAllowedOperator(from) {
        super.transferFrom(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public payable override onlyAllowedOperator(from) {
        super.safeTransferFrom(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data)
        public
        payable
        override
        onlyAllowedOperator(from)
    {
        super.safeTransferFrom(from, to, tokenId, data);
    }

    //=====================================================================
    // [public/override] for ERC165
    //=====================================================================
    function supportsInterface(bytes4 interfaceId) public view override(IERC165, ERC721A, ERC2981) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
