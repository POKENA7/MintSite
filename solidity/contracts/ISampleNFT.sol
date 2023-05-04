// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface ISampleNFT {
    function mint(address to, uint256 quantity) external;
    function totalSupply() external view returns (uint256);
}