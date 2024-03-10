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

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import {DeployMarketplace} from "../script/DeployMarketplace.s.sol";

pragma solidity ^0.8.24;

contract Marketplace {    
    AggregatorV3Interface private s_ethUsdPriceFeed;
    AggregatorV3Interface private s_btcUsdPriceFeed;

    constructor(address ethPriceFeed, address btcPriceFeed) {
        s_ethUsdPriceFeed = AggregatorV3Interface(ethPriceFeed);
        s_btcUsdPriceFeed = AggregatorV3Interface(btcPriceFeed);
    }

    struct DeelStruct {
        address seller;
        address buyer;
        ItemStruct item;
        bool isSold;
    }

    struct ItemStruct {
        string title;
        string description;
        uint256 price;
    }

    mapping(address seller => ItemStruct[] item) s_itemsUserIsSelling; // user to items they're selling
    mapping(address seller => DeelStruct[] deel) s_deelsUserPosted; // user to items they're selling

    /**
     * @notice user can post an item to sell in the marketplace
     * @param title name of the item user is selling
     * @param description describes what the user is selling
     * @param price the price the user is selling the item for
     */
    function createDeel(string memory title, string memory description, uint256 price) external {
        ItemStruct memory item = s_itemsUserIsSelling[msg.sender].push();
        item.title = title;
        item.description = description;
        item.price = price;        

        DeelStruct memory deel = s_deelsUserPosted[msg.sender].push();
        deel.seller = msg.sender;
        deel.buyer = address(0);
        deel.item = item;
        deel.isSold = false;
    }

}