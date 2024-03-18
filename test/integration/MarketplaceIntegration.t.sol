// SPDX-License-Identifier: MIT

// Layout of Contract:
// version
// imports
// interfaces, libraries, contracts
// errors
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

pragma solidity ^0.8.24;

import {DeployMarketplace} from "../../script/DeployMarketplace.s.sol";
import {Marketplace} from "../../src/Marketplace.sol";
import {Test} from "forge-std/Test.sol";

contract MarketplaceIntegration is Test {
    event DeelTransaction(address indexed seller, address buyer, Marketplace.DeelStruct deel);
    
    Marketplace marketplace;
    DeployMarketplace deployer;

    uint256 constant SELLER_STARTING_BALANCE = 3 ether;
    uint256 constant BUYER_STARTING_BALANCE = 10 ether;
    uint256 constant PRICE_PRECISION = 10**18;

    address SELLER = makeAddr("seller");
    address BUYER = makeAddr("buyer");

    function setUp() public {
        deployer = new DeployMarketplace();
        marketplace = deployer.run();
        vm.deal(SELLER, SELLER_STARTING_BALANCE);
        vm.deal(BUYER, BUYER_STARTING_BALANCE);
    }

    modifier firstCreateDeel() {
        vm.startPrank(SELLER);

        string memory mockTitle = "Phone";
        string memory mockDescription = "8GB RAM 256GB SSD";
        uint256 mockPrice = .33 ether;
        
        marketplace.createDeel(mockTitle, mockDescription, mockPrice);

        vm.warp(block.timestamp + 60 seconds);
        vm.roll(block.number + 1);

        _;
    }

    // Seller will create and edit an item/deel, buyer will transact deel
    function testEditDeel() public firstCreateDeel{
        string memory mockEditTitle = "Laptop";
        string memory mockEditDescription = "36GB RAM 1TB SSD";
        uint256 mockEditPrice = 1 ether; // $3499

        Marketplace.DeelStruct memory expectedDeel = marketplace.editDeel(0, mockEditTitle, mockEditDescription, mockEditPrice);

        assertEq(expectedDeel.item.title, mockEditTitle);
        assertEq(expectedDeel.item.description, mockEditDescription);
        assertEq(expectedDeel.item.price, mockEditPrice);
        
    }

    function testExpectEmitOnTransaction() public firstCreateDeel {
        vm.startPrank(BUYER);

        Marketplace.DeelStruct memory deel = marketplace.getDeelsUserPosted(SELLER)[0];
        vm.expectEmit(true, true, true, false, address(marketplace));
        emit Marketplace.DeelTransaction(SELLER, BUYER, deel);
        marketplace.transactDeel{value: deel.item.price}(deel);
    }
}
 