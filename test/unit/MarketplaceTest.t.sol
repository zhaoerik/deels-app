// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {DeployMarketplace} from "../../script/DeployMarketplace.s.sol";
import {Marketplace} from "../../src/Marketplace.sol";

contract MarketplaceTest is Test {
    Marketplace marketplace;
    address public USER = makeAddr("user");
    uint256 public constant INITIAL_ETH_BALANCE = 10 ether;

    function setUp() public {
        DeployMarketplace deployer = new DeployMarketplace();
        marketplace = deployer.run();
        vm.deal(USER, INITIAL_ETH_BALANCE);
    }

    function testUserHasNoItemsToSellInTheBeginning() public {
        uint256 numberOfItemsToSell = marketplace.getItemsUserIsSelling(USER).length;
        assertEq(numberOfItemsToSell, 0);
    }

    modifier createsDeel() {
        Marketplace.ItemStruct memory item;
        Marketplace.DeelStruct memory deel;
        string memory title = "Headphones";
        string memory description = "These are high quality headphones";
        uint256 price = 0.05 ether;

        vm.startPrank(USER);
        (item, deel) = marketplace.createDeel(title, description, price);
        vm.stopPrank();

        _;
    }

    function testUserHasOneItemAndOneDeel() public createsDeel {
        uint256 expectedNumberOfItemsToSell = marketplace.getItemsUserIsSelling(USER).length;
        uint256 actualNumberOfItemsToSell = 1;

        uint256 expectedNumberOfDeels = marketplace.getDeelsUserPosted(USER).length;
        uint256 actualNumberOfDeels = 1;

        assertEq(expectedNumberOfItemsToSell, actualNumberOfItemsToSell);
        assertEq(expectedNumberOfDeels, actualNumberOfDeels);
    }

    function testDeelProperties() public createsDeel {
        Marketplace.DeelStruct memory deel = marketplace.getDeelsUserPosted(USER)[0];

        address expectedSeller = deel.seller;
        address actualSeller = USER;

        address expectedBuyer = deel.buyer;
        address actualBuyer = address(0);

        string memory expectedItemTitle = deel.item.title;
        string memory actualItemTitle = "Headphones";
        string memory expectedItemDescription = deel.item.description;
        string memory actualItemDescription = "These are high quality headphones";
        uint256 expectedItemPrice = deel.item.price;
        uint256 actualItemPrice = 5 * 1e16; // 0.05 ether

        bool expectedBool = deel.isSold;
        bool actualBool = false;

        assertEq(expectedSeller, actualSeller);
        assertEq(expectedBuyer, actualBuyer);
        assertEq(expectedItemTitle, actualItemTitle);
        assertEq(expectedItemDescription, actualItemDescription);
        assertEq(expectedItemPrice, actualItemPrice);
        assertEq(expectedBool, actualBool);
    }



}
