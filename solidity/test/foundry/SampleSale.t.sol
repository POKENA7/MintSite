// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../../contracts/SampleNFT.sol";
import "../../contracts/SampleSale.sol";

contract SampleNFTTest is Test {
    SampleNFT public nftContract;
    SampleSale public saleContract;

    string baseURI = "https://hogehoge.com/";

    address admin = vm.addr(1);
    address bob = vm.addr(2);
    address alice = vm.addr(3);

    bytes32[] public proof = new bytes32[](3);

    function setUp() public {
        vm.deal(bob, 10000 ether);
        vm.deal(alice, 10000 ether);

        nftContract = new SampleNFT(baseURI, admin);
        saleContract = new SampleSale(address(nftContract));
        saleContract.setMerkleRoot(0xd141dbfcff28a10896b39ba519bf0a21c65fa7e878bc5e057fa57d9e2665d5f0);
        nftContract.setMinter(address(saleContract));

        vm.warp(saleContract.preSaleStart());

        proof[0] = 0xe9707d0e6171f728f7473c24cc0432a9b07eaaf1efed6a137a4a8c12c79552d9;
        proof[1] = 0xb1a5bda84b83f7f014abcf0cf69cab5a4de1c3ececa8123a5e4aaacb01f63f83;
        proof[2] = 0xee438b8944f2cbadd8fc6ef239ad340564666cbdd5335b9e91481b62ec19c0e3;
    }

    modifier preSaleMint(uint256 quantity) {
        vm.prank(bob);
        saleContract.preSaleMint(quantity, proof);
        // vm.stopPrank();
        _;
    }

    //=====================================================================
    // PreSaleMint
    //=====================================================================
    function testPreSaleMint() public {
        vm.startPrank(bob);
        saleContract.preSaleMint{ value: saleContract.price() }(1, proof);
        saleContract.preSaleMint{ value: saleContract.price() * 2 }(2, proof);
        vm.stopPrank();
        assertEq(nftContract.ownerOf(1), address(bob));
        assertEq(nftContract.ownerOf(2), address(bob));
        assertEq(nftContract.ownerOf(3), address(bob));
    }

    function testPreSaleMintWrongPrice() public {
        vm.prank(bob);
        vm.expectRevert(SaleErrors.WrongPrice.selector);
        saleContract.preSaleMint{ value: 0.00001 ether }(1, proof);
    }

    function testPreSaleMintOutOfSaleTime(uint256 invalidSaleStart, uint256 invalidSaleEnd) public {
        vm.assume(invalidSaleStart < saleContract.preSaleStart() && invalidSaleEnd > saleContract.preSaleEnd());

        uint256 price = saleContract.price();

        vm.startPrank(bob);
        vm.warp(invalidSaleStart);
        vm.expectRevert(SaleErrors.OutOfSaleTime.selector);
        saleContract.preSaleMint{ value: price }(1, proof);

        vm.warp(invalidSaleEnd);
        vm.expectRevert(SaleErrors.OutOfSaleTime.selector);
        saleContract.preSaleMint{ value: price }(1, proof);
        vm.stopPrank();
    } 

    function testPreSaleMintFromInvalidAddress(address invalidAddress) public {
        vm.assume(invalidAddress != bob);

        vm.deal(invalidAddress, 1 ether);
        vm.prank(invalidAddress);
        vm.expectRevert(SaleErrors.InvalidProof.selector);
        saleContract.preSaleMint{ value: 0.05 ether }(1, proof);
    }

    function testPreSaleMintOverLimit(uint256 quantity) public {
        vm.assume(quantity > 0 && quantity <= saleContract.supply() && quantity > saleContract.preSaleLimit());
        uint256 price = saleContract.price();
        
        vm.prank(bob);
        vm.expectRevert(SaleErrors.OverLimit.selector);
        saleContract.preSaleMint{ value: price * quantity }(quantity, proof);
    }

    function testPreSaleMintOverLimitGradually() public {
        uint256 price = saleContract.price();

        vm.startPrank(bob);
        saleContract.preSaleMint{ value: price }(1, proof);
        saleContract.preSaleMint{ value: price }(1, proof);
        saleContract.preSaleMint{ value: price }(1, proof);
        vm.expectRevert(SaleErrors.OverLimit.selector);
        saleContract.preSaleMint{ value: price }(1, proof);
        vm.stopPrank();
    }

    function testInvalidQuantity() public {
        vm.prank(bob);
        vm.expectRevert(SaleErrors.InvalidQuantity.selector);
        saleContract.preSaleMint{ value: 1 ether }(0, proof);
    }

    //=====================================================================
    // PublicSale
    //=====================================================================
    function testPublicSaleMint(address buyer) public {
        vm.assume(buyer != address(0));

        vm.deal(buyer, 1 ether);
        vm.warp(saleContract.publicSaleStart());

        vm.startPrank(buyer);
        saleContract.publicSaleMint{ value: saleContract.price() }(1);
        vm.stopPrank();
        assertEq(nftContract.ownerOf(1), address(buyer));
    }

    function testPublicSaleMintWrongPrice() public {
        vm.warp(saleContract.publicSaleStart());

        vm.prank(bob);
        vm.expectRevert(SaleErrors.WrongPrice.selector);
        saleContract.publicSaleMint{ value: 0.00001 ether }(1);
    }

    function testPublicSaleMintOutOfSaleTime(uint256 invalidSaleStart, uint256 invalidSaleEnd) public {
        vm.assume(invalidSaleStart < saleContract.publicSaleStart() && invalidSaleEnd > saleContract.publicSaleEnd());

        uint256 price = saleContract.price();

        vm.startPrank(bob);
        vm.warp(invalidSaleStart);
        vm.expectRevert(SaleErrors.OutOfSaleTime.selector);
        saleContract.publicSaleMint{ value: price }(1);

        vm.warp(invalidSaleEnd);
        vm.expectRevert(SaleErrors.OutOfSaleTime.selector);
        saleContract.publicSaleMint{ value: price }(1);
        vm.stopPrank();
    }

    //=====================================================================
    // Withdraw
    //=====================================================================
    function testWithdraw() public {
        vm.startPrank(bob);
        saleContract.preSaleMint{ value: saleContract.price() }(1, proof);
        vm.stopPrank();

        address receiver = vm.addr(100);
        saleContract.withdraw(receiver);
        assertEq(receiver.balance, saleContract.price());
    }

    //=====================================================================
    // SaleTime
    //=====================================================================
    function testSetPreSaleTime(uint256 newPreSaleStart, uint256 newPreSaleEnd) public {
        saleContract.setPreSaleStart(newPreSaleStart);
        assertEq(saleContract.preSaleStart(), newPreSaleStart);

        saleContract.setPreSaleEnd(newPreSaleEnd);
        assertEq(saleContract.preSaleEnd(), newPreSaleEnd);
    }

    function testSetPreSaleTimeFromNotOwner(address notOwner, uint256 newPreSaleStart, uint256 newPreSaleEnd) public {
        vm.assume(notOwner != address(this));

        vm.startPrank(notOwner);
        vm.expectRevert();
        saleContract.setPreSaleStart(newPreSaleStart);

        vm.expectRevert();
        saleContract.setPreSaleEnd(newPreSaleEnd);
        vm.stopPrank();
    }

    function testSetPublicSaleTime(uint256 newPublicSaleStart, uint256 newPublicSaleEnd) public {
        saleContract.setPublicSaleStart(newPublicSaleStart);
        assertEq(saleContract.publicSaleStart(), newPublicSaleStart);

        saleContract.setPublicSaleEnd(newPublicSaleEnd);
        assertEq(saleContract.publicSaleEnd(), newPublicSaleEnd);
    }

    function testSetPublicSaleTimeFromNotOwner(address notOwner, uint256 newPublicSaleStart, uint256 newPublicSaleEnd) public {
        vm.assume(notOwner != address(this));

        vm.startPrank(notOwner);
        vm.expectRevert();
        saleContract.setPublicSaleStart(newPublicSaleStart);

        vm.expectRevert();
        saleContract.setPublicSaleEnd(newPublicSaleEnd);
        vm.stopPrank();
    }

    //=====================================================================
    // SaleLimit
    //=====================================================================
    function testSetPreSaleLimit(uint256 newLimit) public {
        saleContract.setPreSaleLimit(newLimit);
        assertEq(saleContract.preSaleLimit(), newLimit);
    }

    function testSetPreSaleLimitFromNotOwner(uint256 newLimit, address invalidAddress) public {
        vm.assume(invalidAddress != address(0) && invalidAddress != address(this));

        vm.prank(invalidAddress);
        vm.expectRevert();
        saleContract.setPreSaleLimit(newLimit);
    }

    function testSetPublicSaleLimit(uint256 newLimit) public {
        saleContract.setPublicSaleLimit(newLimit);
        assertEq(saleContract.publicSaleLimit(), newLimit);
    }

    function testSetPublicSaleLimitFromNotOwner(uint256 newLimit, address invalidAddress) public {
        vm.assume(invalidAddress != address(0));

        vm.prank(invalidAddress);
        vm.expectRevert();
        saleContract.setPublicSaleLimit(newLimit);
    }

    //=====================================================================
    // SetSupply
    //=====================================================================
    function testSetSupply(uint256 newSupply) public {
        saleContract.setSupply(newSupply);
        assertEq(saleContract.supply(), newSupply);
    }

    function testSetSupplyFromInvalidAddress(uint256 newSupply, address invalidAddress) public {
        vm.assume(invalidAddress != address(this));

        vm.prank(invalidAddress);
        vm.expectRevert();
        saleContract.setSupply(newSupply);
    }

    //=====================================================================
    // CheckPreSaleEligible
    //=====================================================================
    function testCheckPreSaleEligible(address invalidAddress) public {
        assertEq(saleContract.checkPreSaleEligible(bob, proof), true);
        assertEq(saleContract.checkPreSaleEligible(invalidAddress, proof), false);
    }

    //=====================================================================
    // CheckRemaining
    //=====================================================================
    function testCheckPreSaleRemaining() public {
        assertEq(saleContract.checkPreSaleRemaining(bob), saleContract.preSaleLimit());
        vm.startPrank(bob);
        saleContract.preSaleMint{ value: saleContract.price() }(1, proof);
        assertEq(saleContract.checkPreSaleRemaining(bob), saleContract.preSaleLimit() - 1);
    }

    function testCheckPublicSaleRemaining() public {
        assertEq(saleContract.checkPublicSaleRemaining(bob), saleContract.publicSaleLimit());
        vm.startPrank(bob);
        vm.warp(saleContract.publicSaleStart());
        saleContract.publicSaleMint{ value: saleContract.price() }(1);
        assertEq(saleContract.checkPublicSaleRemaining(bob), saleContract.publicSaleLimit() - 1);
    }

    //=====================================================================
    // Others
    //=====================================================================
    function testPreSaleMintDirectly() public {
        vm.prank(bob);
        vm.expectRevert(NFTErrors.NotMinter.selector);
        nftContract.mint(address(bob), 1);
    }
}