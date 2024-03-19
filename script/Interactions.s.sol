// Fund
// Withdraw

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundFundMe is Script {
    //script for funding the FundMe contract

    uint256 constant SEND_VALUE = 0.1 ether;

    function fundFundMe(address mostRecentlyDeployed) public {
        console.log(
            "Account balance before funding: %s",
            address(this).balance
        );
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployed)).fund{value: SEND_VALUE}();
        vm.stopBroadcast();
        console.log("Funded FundMe with %s", SEND_VALUE);
    }

    function run() external {
        //we're gonna have our run function call our fundFundMe function
        //we'll most probably work on the most recently deployed version of the contract //install Cyfrin/foundry-devops
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe", //we pass the name of the contract FundMe
            block.chainid //it looks inside of the broadcast folder based off chain id, picks the run-latest.json and grabs the most recently deployed contract in that file
        );

        //vm.startBroadcast();
        fundFundMe(mostRecentlyDeployed);
        //vm.stopBroadcast();
    }
}

contract WithdrawFundMe is Script {
    //script for withdrawing from the FundMe contract
    function withdrawFundMe(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployed)).withdraw();
        vm.stopBroadcast();
        console.log("Remaining balance:", address(this).balance);
    }

    function run() external {
        //we're gonna have our run function call our fundFundMe function
        //we'll most probably work on the most recently deployed version of the contract //install Cyfrin/foundry-devops
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe", //we pass the name of the contract FundMe
            block.chainid //it looks inside of the broadcast folder based off chain id, picks the run-latest.json and grabs the most recently deployed contract in that file
        );

        //vm.startBroadcast();
        withdrawFundMe(mostRecentlyDeployed);
        //vm.stopBroadcast();
    }
}
