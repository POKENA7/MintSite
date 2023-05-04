// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./ISampleNFT.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

library SaleErrors {
    error WrongPrice();
    error InvalidProof();
    error InvalidQuantity();
    error OutOfSaleTime();
    error OverLimit();
    error OverSupply();
}

contract SampleSale is Ownable {
    ISampleNFT public nft;
    uint256 public price = 0.05 ether;
    uint256 public supply = 1000;
    uint256 public preSaleStart = 1682866800; // 2023/5/1   0:00
    uint256 public preSaleEnd   = 1685458800; // 2023/5/31  0:00
    uint256 public publicSaleStart = 1685545200; // 2023/6/1   0:00
    uint256 public publicSaleEnd   = 1703948400; // 2023/12/31 0:00
    uint256 public preSaleLimit    = 3;
    uint256 public publicSaleLimit = 5;
    mapping(address => uint256) public addressToPreSaleMinted;
    mapping(address => uint256) public addressToPublicSaleMinted;

    bytes32 public merkleRoot;

    constructor(address _nft) {
        nft = ISampleNFT(_nft);
    }

    function publicSaleMint(uint256 _quantity) external payable {
        if (_quantity <= 0) revert SaleErrors.InvalidQuantity();
        if (nft.totalSupply() + _quantity > supply) revert SaleErrors.OverSupply();
        if (publicSaleStart > block.timestamp || block.timestamp > publicSaleEnd) revert SaleErrors.OutOfSaleTime();
        if (_quantity + addressToPublicSaleMinted[msg.sender] > publicSaleLimit) revert SaleErrors.OverLimit();
        if (msg.value != price * _quantity) revert SaleErrors.WrongPrice();

        nft.mint(msg.sender, _quantity);
        addressToPublicSaleMinted[msg.sender] += _quantity;
    }

    function preSaleMint(uint256 _quantity, bytes32[] calldata _proof) external payable {
        if (_quantity <= 0) revert SaleErrors.InvalidQuantity();
        if (nft.totalSupply() + _quantity > supply) revert SaleErrors.OverSupply();
        if (preSaleStart > block.timestamp || block.timestamp > preSaleEnd) revert SaleErrors.OutOfSaleTime();
        if (_quantity + addressToPreSaleMinted[msg.sender] > preSaleLimit) revert SaleErrors.OverLimit();
        if (msg.value != price * _quantity) revert SaleErrors.WrongPrice();

        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        if (!MerkleProof.verify(_proof, merkleRoot, leaf)) revert SaleErrors.InvalidProof();
        nft.mint(msg.sender, _quantity);
        addressToPreSaleMinted[msg.sender] += _quantity;
    }

    function withdraw(address _to) external onlyOwner {
        uint256 balance = address(this).balance;
        if (balance <= 0) revert();
        (bool success, ) = _to.call{value: balance}("");
        if(!success) revert();
    }

    function setMerkleRoot(bytes32 _root) external onlyOwner {
        merkleRoot = _root;
    }

    function setPreSaleStart(uint256 _preSaleStart) external onlyOwner {
        preSaleStart = _preSaleStart;
    }

    function setPreSaleEnd(uint256 _preSaleEnd) external onlyOwner {
        preSaleEnd = _preSaleEnd;
    }

    function setPublicSaleStart(uint256 _publicSaleStart) external onlyOwner {
        publicSaleStart = _publicSaleStart;
    }

    function setPublicSaleEnd(uint256 _publicSaleEnd) external onlyOwner {
        publicSaleEnd = _publicSaleEnd;
    }

    function setPreSaleLimit(uint256 _preSaleLimit) external onlyOwner {
        preSaleLimit = _preSaleLimit;
    }
    
    function setPublicSaleLimit(uint256 _publicSaleLimit) external onlyOwner {
        publicSaleLimit = _publicSaleLimit;
    }

    function setSupply(uint256 _supply) external onlyOwner {
        supply = _supply;
    }

    function checkPreSaleEligible(address _user, bytes32[] calldata _proof) public view returns (bool) {
        bytes32 leaf = keccak256(abi.encodePacked(_user));
        return MerkleProof.verify(_proof, merkleRoot, leaf);
    }

    function checkPreSaleRemaining(address _user) public view returns (uint256) {
        return preSaleLimit - addressToPreSaleMinted[_user];
    }

    function checkPublicSaleRemaining(address _user) public view returns (uint256) {
        return publicSaleLimit - addressToPublicSaleMinted[_user];
    }

    function totalSupply() public view returns (uint256) {
        return nft.totalSupply();
    }
}