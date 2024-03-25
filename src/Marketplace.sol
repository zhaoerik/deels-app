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

import {DeployMarketplace} from "../script/DeployMarketplace.s.sol";

pragma solidity ^0.8.18;

contract Marketplace {
    ///////////////
    // Errors    //
    ///////////////
    error Error__UserHasNoDeel();
    error Error__PriceHasToBeGreaterThanZero();
    error Error__IdNotFound(uint256 _id);
    error Error__TransactionFailed();

    ////////////////////////
    // State Variables    //
    ////////////////////////
    mapping(address seller => ItemStruct[] item) s_itemsUserIsSelling; // user to items they're selling
    mapping(address seller => DeelStruct[] deel) public s_deelsUserPosted; // user to items they're selling
    mapping(address buyer => ItemStruct[] item) s_itemsUserBought; // user to items they bought

    struct DeelStruct {
        uint256 id;
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

    ///////////////
    // Events    //
    ///////////////
    event DeelCreation(uint256 indexed id, address indexed seller, string title, string description, uint256 price);
    event DeelEdit(address indexed seller, string title, string description, uint256 price);
    event DeelTransaction(address indexed seller, address buyer, DeelStruct deel);

    ////////////////
    // Functions  //
    ////////////////
    constructor() {}

    /**
     * @notice user can post an item to sell in the marketplace
     * @param _title name of the item user is selling
     * @param _description describes what the user is selling
     * @param _price the price the user is selling the item for
     */
    function createDeel(string memory _title, string memory _description, uint256 _price)
        external
        returns (ItemStruct memory, DeelStruct memory)
    {
        if (_price <= 0) {
            revert Error__PriceHasToBeGreaterThanZero();
        }

        ItemStruct memory item;
        item.title = _title;
        item.description = _description;
        item.price = _price;

        s_itemsUserIsSelling[msg.sender].push(item);

        DeelStruct memory deel;
        uint256 _id = s_deelsUserPosted[msg.sender].length;
        deel.id = _id;
        deel.seller = msg.sender;
        deel.buyer = address(0);
        deel.item = item;
        deel.isSold = false;

        emit DeelCreation(deel.id, msg.sender, item.title, item.description, item.price);
        s_deelsUserPosted[msg.sender].push(deel);

        return (item, deel); // necessary?
    }

    /**
     * @notice integration test
     * @param _id deel id
     * @param _title edited title
     * @param _description edited description
     * @param _price edited price
     */
    function editDeel(uint256 _id, string memory _title, string memory _description, uint256 _price)
        external
        returns (DeelStruct memory)
    {
        if (_price <= 0) {
            revert Error__PriceHasToBeGreaterThanZero();
        }

        if (_id >= s_deelsUserPosted[msg.sender].length) {
            revert Error__IdNotFound(_id);
        }

        DeelStruct memory deel = s_deelsUserPosted[msg.sender][_id];
        emit DeelEdit(msg.sender, deel.item.title, deel.item.description, deel.item.price);

        // does NOT give the intended behavior in some cases, so it must be used with caution
        if (bytes(_title).length > 0) {
            deel.item.title = _title;
        }
        if (bytes(_description).length > 0) {
            deel.item.description = _description;
        }
        if (deel.item.price != _price) {
            deel.item.price = _price;
        }

        return deel;
    }

    /**
     * @notice flip isSold to true ✅
     * @notice change deel buyer to buyer address ✅
     * @notice append to s_itemsUserBought[buyer] ✅
     * @notice error for transaction failure ✅
     * @notice emit event ✅
     * @notice payment ✅
     * @param deel the transaction the buyer will process
     */
    function transactDeel(DeelStruct memory deel) external payable {
        address seller = deel.seller;
        emit DeelTransaction(seller, msg.sender, deel);
        s_deelsUserPosted[seller][deel.id] = DeelStruct({
            id: deel.id,
            seller: deel.seller,
            buyer: msg.sender,
            item: deel.item,
            isSold: true
        });

        s_itemsUserBought[msg.sender].push(deel.item);

        (bool success,) = payable(seller).call{value: deel.item.price}("");
        if (!success) {
            revert Error__TransactionFailed();
        }
    }

    ////////////////////////////
    // External Functions     //
    ////////////////////////////

    function getDeelsUserPosted(address user) external view returns (DeelStruct[] memory) {
        return s_deelsUserPosted[user];
    }
    function getItemsUserIsSelling(address user) external view returns (ItemStruct[] memory) {
        return s_itemsUserIsSelling[user];
    }

    function getItemsUserBought(address user) external view returns (ItemStruct[] memory) {
        return s_itemsUserBought[user];
    }
}
