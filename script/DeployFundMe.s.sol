//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        // Before startBroadcast, no real tx; it's gonna simulate on a simulated environment
        HelperConfig helperConfig = new HelperConfig();
        address ethUSDPriceFeed = helperConfig.activeNetworkConfig();

        // After startBroadcast, real tx and will cost gas!
        vm.startBroadcast();
        FundMe fundMe = new FundMe(ethUSDPriceFeed);
        vm.stopBroadcast();
        return fundMe;
    }
}
