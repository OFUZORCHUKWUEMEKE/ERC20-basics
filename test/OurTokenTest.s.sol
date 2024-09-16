// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import {Test, console} from "forge-std/Test.sol";
import {Counter} from "../src/Counter.sol";

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {DeployToken} from "../script/DeployOurToken.s.sol";
import {OurToken} from "../src/OurToken.sol";

contract OurTokenTest is Test {
    OurToken public ourToken;
    DeployToken public deployer;

    address bob = makeAddr("bob");
    address alice = makeAddr("alice");

    uint256 public constant STARTING_BALANCE = 100 ether;

    function setUp() public {
        deployer = new DeployToken();
        ourToken = deployer.run();

        vm.prank(msg.sender);
        ourToken.transfer(bob, STARTING_BALANCE);
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
    }

    function testBobBalance() public {
        assertEq(STARTING_BALANCE, ourToken.balanceOf(bob));
    }

    function testIncreaseAllowance() public {
        uint256 initialAllowance = 100;
        uint256 increasedAmount = 50;

        ourToken.approve(user1, initialAllowance);
        assertTrue(ourToken.increaseAllowance(user1, increasedAmount));
        assertEq(
            ourToken.allowance(deployerAddress, user1),
            initialAllowance + increasedAmount
        );
    }

    function testTransferFromInsufficientAllowance() public {
        uint256 approvedAmount = 100;
        uint256 transferAmount = approvedAmount + 1;
        ourToken.approve(user1, approvedAmount);

        vm.prank(user1);
        vm.expectRevert("ERC20: insufficient allowance");
        ourToken.transferFrom(deployerAddress, user2, transferAmount);
    }

    function testDecreaseAllowance() public {
        uint256 initialAllowance = 100;
        uint256 decreasedAmount = 50;

        ourToken.approve(user1, initialAllowance);
        assertTrue(ourToken.decreaseAllowance(user1, decreasedAmount));
        assertEq(
            ourToken.allowance(deployerAddress, user1),
            initialAllowance - decreasedAmount
        );
    }

    function testBurnTokens() public {
        uint256 burnAmount = 100;
        uint256 initialSupply = ourToken.totalSupply();

        ourToken.transfer(user1, burnAmount);

        vm.prank(user1);
        ourToken.transfer(address(0), burnAmount);

        assertEq(ourToken.totalSupply(), initialSupply - burnAmount);
        assertEq(ourToken.balanceOf(user1), 0);
    }

    function testTransferEvent() public {
        uint256 amount = 100;
        vm.expectEmit(true, true, false, true);
        emit Transfer(deployerAddress, user1, amount);
        ourToken.transfer(user1, amount);
    }

    function testApprovalEvent() public {
        uint256 amount = 100;
        vm.expectEmit(true, true, false, true);
        emit Approval(deployerAddress, user1, amount);
        ourToken.approve(user1, amount);
    }
}
