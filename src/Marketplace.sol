// SPDX-License-Identifier: MIT

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {DeployMarketplace} from "../script/DeployMarketplace.s.sol";

pragma solidity ^0.8.18;

contract Marketplace {
    error Error__UserHasNoDeel();

    uint256 public constant PRECISION = 1e18;

    AggregatorV3Interface private s_ethUsdPriceFeed;

    constructor(address ethPriceFeed) {
        s_ethUsdPriceFeed = AggregatorV3Interface(ethPriceFeed);
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
    function createDeel(string memory title, string memory description, uint256 price) external returns (ItemStruct memory, DeelStruct memory) {
        ItemStruct memory item; 
        item.title = title;
        item.description = description;
        item.price = price;
        s_itemsUserIsSelling[msg.sender].push(item);

        DeelStruct memory deel;
        deel.seller = msg.sender;
        deel.buyer = address(0);
        deel.item = item;
        deel.isSold = false;
        s_deelsUserPosted[msg.sender].push(deel);

        return (item, deel);
    }



    ////////////////////////////
    // External Functions //////
    ////////////////////////////

    function getItemsUserIsSelling(address user) external view returns (ItemStruct[] memory) {
        return s_itemsUserIsSelling[user];
    }

    function getDeelsUserPosted(address user) external view returns (DeelStruct[] memory) {
        return s_deelsUserPosted[user];
    }
}
