// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../../contracts/SampleNFT.sol";
import "operator-filter-registry/src/OperatorFilterer.sol";

contract SampleNFTTest is Test {
    SampleNFT public nft;

    address admin = vm.addr(1);
    address bob = vm.addr(2);
    address alice = vm.addr(3);

    string baseURI = "https://hogehoge.com/";

    event BatchMetadataUpdate(uint256 _fromTokenId, uint256 _toTokenId);

    function setUp() public {
        nft = new SampleNFT(baseURI, admin);
    }

    modifier mint(uint256 quantity) {
        nft.ownerMint(bob, quantity);
        _;
    }

    // 正常系

    function testMint() public {
        nft.ownerMint(bob, 1);
        assertEq(nft.ownerOf(1), bob);
    }

    function testTokenURI() public mint(3) {
        assertEq(nft.tokenURI(1), string(abi.encodePacked(baseURI, _toString(1), nft.suffix())));
        assertEq(nft.tokenURI(2), string(abi.encodePacked(baseURI, _toString(2), nft.suffix())));
        assertEq(nft.tokenURI(3), string(abi.encodePacked(baseURI, _toString(3), nft.suffix())));
    }

    function testSetBaseURI() public mint(3) {
        string memory newBaseURI = "https://fugafuga.com/";
        vm.expectEmit(true, true, false, true);
        emit BatchMetadataUpdate(1, type(uint256).max);
        nft.setBaseURI(newBaseURI);
        assertEq(nft.tokenURI(1), string(abi.encodePacked(newBaseURI, _toString(1), nft.suffix())));
        assertEq(nft.tokenURI(2), string(abi.encodePacked(newBaseURI, _toString(2), nft.suffix())));
        assertEq(nft.tokenURI(3), string(abi.encodePacked(newBaseURI, _toString(3), nft.suffix())));
    }

    function testRoyality() public {
        (address receiver, uint256 amount) = nft.royaltyInfo(0, 1 ether);
        assertEq(receiver, admin);
        assertEq(amount, 0.05 ether); // 5%

        nft.setRoyaltyInfo(bob, 1000);
        (receiver, amount) = nft.royaltyInfo(0, 1 ether);
        assertEq(receiver, bob);
        assertEq(amount, 0.1 ether); // 10%
    }

    function testOperatorFilter() public mint(1) {
        address notAllowedOperator = 0xf42aa99F011A1fA7CDA90E5E98b277E306BcA83e; // LooksRare TransferManagerERC721

        vm.expectRevert(); // ToDo: set NotAllowedOperator error
        nft.setApprovalForAll(notAllowedOperator, true);

        vm.expectRevert(); // ToDo: set NotAllowedOperator error
        nft.approve(notAllowedOperator, 0);

        vm.startPrank(notAllowedOperator);
        vm.expectRevert(); // ToDo: set NotAllowedOperator error
        nft.transferFrom(address(this), alice, 0);

        vm.expectRevert(); // ToDo: set NotAllowedOperator error
        nft.safeTransferFrom(bob, alice, 0);

        vm.expectRevert(); // ToDo: set NotAllowedOperator error
        nft.safeTransferFrom(bob, alice, 0, "");
    }


    /**
     * @dev Converts a uint256 to its ASCII string decimal representation.
     */
    function _toString(uint256 value) internal pure virtual returns (string memory str) {
        assembly {
            // The maximum value of a uint256 contains 78 digits (1 byte per digit), but
            // we allocate 0xa0 bytes to keep the free memory pointer 32-byte word aligned.
            // We will need 1 word for the trailing zeros padding, 1 word for the length,
            // and 3 words for a maximum of 78 digits. Total: 5 * 0x20 = 0xa0.
            let m := add(mload(0x40), 0xa0)
            // Update the free memory pointer to allocate.
            mstore(0x40, m)
            // Assign the `str` to the end.
            str := sub(m, 0x20)
            // Zeroize the slot after the string.
            mstore(str, 0)

            // Cache the end of the memory to calculate the length later.
            let end := str

            // We write the string from rightmost digit to leftmost digit.
            // The following is essentially a do-while loop that also handles the zero case.
            // prettier-ignore
            for { let temp := value } 1 {} {
                str := sub(str, 1)
                // Write the character to the pointer.
                // The ASCII index of the '0' character is 48.
                mstore8(str, add(48, mod(temp, 10)))
                // Keep dividing `temp` until zero.
                temp := div(temp, 10)
                // prettier-ignore
                if iszero(temp) { break }
            }

            let length := sub(end, str)
            // Move the pointer 32 bytes leftwards to make room for the length.
            str := sub(str, 0x20)
            // Store the length.
            mstore(str, length)
        }
    }
}