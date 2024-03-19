//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether; //giving USER some fake money to run our test (for the deal cheatcode)
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        // fundMe = new FundMe(); //our fundme variable of type FundMe is gonna be a new FundMe contract
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE); //deals sets the balance of an address 'who' to 'newBalance' - funds some money to a user
    }

    function testMinimUmDollarIsFive() public {
        assertEq(fundMe.MINIMUM_USD(), 5 * 10 ** 18);
    }

    function testOwnerIsMsgSender() public {
        console.log(fundMe.getOwner());
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public {
        uint256 version = fundMe.getVersion(); //this would fail everytime if the contract doesn't exist on anvil
        assertEq(version, 4);
    }

    function testFundFailsWithoutEnoughEth() public {
        vm.expectRevert(); //hey, the next line should revert!
        //assert(this tx fails/reverts)
        fundMe.fund(); //i.e. send 0 value which is < the minimumUSD in the fund function of fundme.sol
    }

    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER); //the next tx, that fund below, will be sent by USER - better way vs confusing way of figuring out who the sender of the tx is
        fundMe.fund{value: SEND_VALUE}(); //prank code sets msg.sender to the specified address for the next call, meaning fundMe.fund will be sent by USER.

        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER); //replace address(this) with USER
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsFunderToArrayOfFunders() public {
        //I'M NOT SURE HOW THIS TEST ACTUALLY ADDS FUNDER TO THE ARRAY OF FUNDERS
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();

        address funder = fundMe.getFunder(0);
        assertEq(funder, USER); //test is checking if funder is same as user
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.prank(USER); //say user wants to pretend to be the owner for line 65 who can withdraw
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() public funded {
        //Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance; //actual balance of the fundme contract - just the send_value

        //Act
        //uint256 gasStart = gasleft(); //gasleft is built-in that tells how much gas is left in your tx call
        //vm.txGasPrice(GAS_PRICE); //putting in GAS_PRICE so we'll have gas price in our test
        vm.prank(fundMe.getOwner());
        fundMe.withdraw(); //it's in this Act section because we're testing the withdraw function //should have spent gas???
        //to simulate the actual gas price, we need to tell our test to pretend to use a real gas price
        //use .txGasPrice - sets .txgasprice for the rest of the transaction
        //to see how much gas we're actually gonna spend, we need to calculate the gas left in this function call BEFORE and AFTER.
        // uint256 gasEnd = gasleft();
        // uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice; //tx.gasprice is another built-in that tells the current gas price
        // console.log(gasUsed);

        //Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0); //assuming we withdraw all the fundme balance
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance
        );
    }

    function testWithdrawFromMultipleFunders() public funded {
        //Arrange
        //funders loop through the list in lines 93-99 and then fund our contract
        uint160 numberOfFunders = 10; //uint160 has the same amount of bytes as an address
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            //vm.prank for new address
            //vm.deal for new money
            //address() - indicate the index in the hoax
            hoax(address(i), SEND_VALUE); //hoax is combination of prank and deal; prank and put some money on this address //create a blank address of i
            //fund the fundMe
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        //Act
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        //Assert
        assert(address(fundMe).balance == 0); //removing all the funds of fundMe that's why it's zero
        assert(
            startingFundMeBalance + startingOwnerBalance ==
                fundMe.getOwner().balance
        );
    }

    function testWithdrawFromMultipleFundersCheaper() public funded {
        //Arrange
        //funders loop through the list in lines 93-99 and then fund our contract
        uint160 numberOfFunders = 10; //uint160 has the same amount of bytes as an address
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            //vm.prank for new address
            //vm.deal for new money
            //address() - indicate the index in the hoax
            hoax(address(i), SEND_VALUE); //hoax is combination of prank and deal; prank and put some money on this address //create a blank address of i
            //fund the fundMe
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        //Act
        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        //Assert
        assert(address(fundMe).balance == 0); //removing all the funds of fundMe that's why it's zero
        assert(
            startingFundMeBalance + startingOwnerBalance ==
                fundMe.getOwner().balance
        );
    }
}
