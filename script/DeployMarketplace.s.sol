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

import {Script} from "forge-std/Script.sol";
import {Marketplace} from "../src/Marketplace.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";

contract DeployMarketplace is Script {
    function run() external returns (Marketplace, HelperConfig) {
        uint256 deployerKey;
        address ethUsdPriceFeedAddress;
        address btcUsdPriceFeedAddress;

        HelperConfig config = new HelperConfig();
        (deployerKey, ethUsdPriceFeedAddress, btcUsdPriceFeedAddress) = config.activeNetworkConfig();

        vm.startBroadcast();
        Marketplace marketplace = new Marketplace(ethUsdPriceFeedAddress, btcUsdPriceFeedAddress);
        vm.stopBroadcast();

        return (marketplace, config);    
    }
}