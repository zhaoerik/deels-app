// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    struct NetworkConfig {
        uint256 deployerKey;
        address ethUsdPriceFeedAddress;
        address btcUsdPriceFeedAddress;
    }

    NetworkConfig public activeNetworkConfig;
    uint8 public constant DECIMALS = 8;
    int256 public constant ETHER_PRICE = 3000e8;
    int256 public constant BITCOIN_PRICE = 69000e8;

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public view returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            deployerKey: vm.envUint("SEPOLIA_PRIVATE_KEY"),
            ethUsdPriceFeedAddress: 0x694AA1769357215DE4FAC081bf1f309aDC325306,
            btcUsdPriceFeedAddress: 0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43
        });
        return sepoliaConfig;
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.ethUsdPriceFeedAddress != address(0)) {
            return activeNetworkConfig;
        } else {
            vm.startBroadcast();
            MockV3Aggregator mockEthPriceFeed = new MockV3Aggregator(DECIMALS, ETHER_PRICE);
            MockV3Aggregator mockBtcPriceFeed = new MockV3Aggregator(DECIMALS, BITCOIN_PRICE);
            vm.stopBroadcast();

            NetworkConfig memory anvilConfig = NetworkConfig({
                deployerKey: vm.envUint("ANVIL_PRIVATE_KEY"),
                ethUsdPriceFeedAddress: address(mockEthPriceFeed),
                btcUsdPriceFeedAddress: address(mockBtcPriceFeed)
            });

            return anvilConfig;
        }
    }
}
