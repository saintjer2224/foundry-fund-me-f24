//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    //If we are on a local Anvil chain, we deploy mocks.
    //Otherwise, grab the existing address from the live network.

    NetworkConfig public activeNetworkConfig;

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    struct NetworkConfig {
        // will need this setup if multiple inputs inside each fx i.e. turn the configs into each own type
        address priceFeed; //ETH/USD price feed address
    }

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 1) {
            activeNetworkConfig = getMainnetEthConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        //return a config for everything we need in Sepolia
        //this is the way to grab the existing address from the live network
        //will need the price feed address
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaConfig;
    }

    function getMainnetEthConfig() public pure returns (NetworkConfig memory) {
        //return a config for everything we need in Sepolia
        //this is the way to grab the existing address from the live network
        //will need the price feed address
        NetworkConfig memory ethConfig = NetworkConfig({
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });
        return ethConfig;
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        //renaming to getOrCreateAnvilEthConfig to reflect the current operations done
        //will need the price feed address
        //1. Deploy the mock (fake/dummy contract)
        //2. Return the mock address
        if (activeNetworkConfig.priceFeed != address(0)) {
            //this block only checking if price feed has been set up; if not 0, then address has been set up
            //address(0) i.e. address defaults to address 0
            return activeNetworkConfig;
        }

        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            DECIMALS,
            INITIAL_PRICE
        ); //8 as the number of decimals of eth/usd; 2000 as the sample initial answer/price
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({ //this block deploys our own fake price feed
            priceFeed: address(mockPriceFeed)
        });
        return anvilConfig;
    }
}

// 1. Deploy mocks when we are on local Anvil chain
// 2. Keep track of contract addresses across different chains (be able to work with any chain we want with no problem)
// e.g. Sepolia ETH/USD has a diff. address
// e.g. Mainnet ETH/USD has a diff. address
