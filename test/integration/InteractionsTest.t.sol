//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol"; //using this instead of directly funding the fund functions, import FundFundMe

contract InteractionsTest is Test {
    FundMe fundMe;

    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.5 ether; //100000000000000000
    uint256 constant STARTING_BALANCE = 10 ether; //giving USER some fake money to run our test (for the deal cheatcode)
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        DeployFundMe deploy = new DeployFundMe();
        fundMe = deploy.run(); //in Patrick's Github, he inserted a helperconfig!
        vm.deal(USER, STARTING_BALANCE); //deals sets the balance of an address 'who' to 'newBalance' - funds some money to a user
    }

    function testUserCanFundAndWithdrawInteractions() public {
        FundFundMe fundFundMe = new FundFundMe();
        //vm.prank(USER);
        //vm.deal(USER, 5e18);
        fundFundMe.fundFundMe(address(fundMe));

        //address funder = fundMe.getFunder(0);
        //assertEq(funder, USER); //test is checking if funder is same as user
        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));

        assert(address(fundMe).balance == 0);
    }
}
