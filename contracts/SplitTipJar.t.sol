// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {SplitTipJar} from "./SplitTipJar.sol";

contract SplitTipJarTest is Test {
    SplitTipJar jar;
    address owner;
    address recipient;

    receive() external payable {}

    function setUp() public {
        owner = address(this);
        recipient = address(0xBEEF);
        jar = new SplitTipJar(recipient, 2_000);
        vm.deal(address(this), 2 ether);
        vm.deal(address(0xCAFE), 2 ether);
    }

    function test_TipSplitsAndRecords() public {
        vm.prank(address(0xCAFE));
        jar.tip{value: 1 ether}("Thanks!");

        assertEq(jar.getTipsCount(), 1);
        SplitTipJar.Tip memory sentTip = jar.getTip(0);
        assertEq(sentTip.sender, address(0xCAFE));
        assertEq(sentTip.amount, 1 ether);
        assertEq(sentTip.message, "Thanks!");
    }

    function test_RevertWhenTippingZero() public {
        vm.expectRevert(SplitTipJar.ZeroTip.selector);
        jar.tip("");
    }

    function test_RevertForInvalidSplit() public {
        vm.expectRevert(SplitTipJar.InvalidSplit.selector);
        new SplitTipJar(recipient, 10_001);
    }
}
