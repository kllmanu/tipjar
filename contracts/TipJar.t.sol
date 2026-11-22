// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {TipJar} from "./TipJar.sol";
import {TipJarFactory} from "./TipJarFactory.sol";

contract TipJarTest is Test {
    receive() external payable {}

    function test_AmountUnlockAllowsWithdrawal() public {
        TipJar jar = new TipJar(address(this), "Concert fund", 1 ether, 0);
        vm.deal(address(this), 2 ether);
        jar.tip{value: 1 ether}("Funded");

        assertTrue(jar.canWithdraw());
        jar.withdraw();

        assertTrue(jar.withdrawn());
        assertEq(address(jar).balance, 0);
    }

    function test_DateUnlockAllowsWithdrawal() public {
        uint256 unlockTime = block.timestamp + 1 days;
        TipJar jar = new TipJar(address(this), "Weekend fund", 0, unlockTime);

        vm.expectRevert(TipJar.WithdrawLocked.selector);
        jar.withdraw();

        vm.warp(unlockTime);
        assertTrue(jar.canWithdraw());
    }


    function test_RevertWhenNoUnlockCondition() public {
        vm.expectRevert(TipJar.InvalidUnlockCondition.selector);
        new TipJar(address(this), "Empty jar", 0, 0);
    }

    function test_RevertWhenPastUnlockDate() public {
        vm.expectRevert(TipJar.InvalidUnlockCondition.selector);
        new TipJar(address(this), "Past jar", 0, block.timestamp);
    }

    function test_RevertForNonOwnerWithdrawal() public {
        TipJar jar = new TipJar(address(this), "Private fund", 1 ether, 0);
        vm.deal(address(this), 1 ether);
        jar.tip{value: 1 ether}("");

        vm.prank(address(0xBEEF));
        vm.expectRevert(TipJar.NotOwner.selector);
        jar.withdraw();
    }
}
