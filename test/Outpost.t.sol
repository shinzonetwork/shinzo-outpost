// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Outpost} from "../src/Outpost.sol";

contract OutpostTest is Test {
    Outpost public outpost;

    function setUp() public {
        outpost = new Outpost();
        vm.deal(address(this), 100 ether);
    }

    function test_setup() public {
        uint256 initialCount = outpost.getPaymentCount(address(this));
        assertEq(initialCount, 0);
        uint256 newIndex = outpost.payment{value: 1}("policy1", "identity1", 1);
        assertEq(newIndex, 0);
        assertEq(outpost.getPaymentAmount(address(this), newIndex), 1);
    }

    function test_Payment() public {
        uint256 index = outpost.payment{value: 1}("policy1", "identity1", 1);
        assertEq(index, 0);
    }

    function testFuzz_Payment(string memory policyId, string memory identity, uint256 value) public {
        vm.assume(value > 0);
        vm.assume(bytes(policyId).length > 0);
        vm.assume(bytes(identity).length > 0);
        vm.assume(value < 100 ether);

        uint256 expectedIndex = outpost.getPaymentCount(address(this));
        uint256 index = outpost.payment{value: value}(policyId, identity, 1);
        assertEq(index, expectedIndex);
    }

    function test_PolicyIsLinkedToDigitalID() public {
        outpost.payment{value: 1}("policy1", "identity1", 1);
        Outpost.DigitalID memory digitalId = outpost.getDigitalId(address(this));
        assertEq(digitalId.policies.length, 1);
        assertEq(digitalId.policies[0].policyId, "policy1");
        assertNotEq(digitalId.policies[0].policyPaymentId, bytes32(0));
    }

    function test_ExpirePayment() public {
        uint256 index = outpost.payment{value: 1}("policy1", "identity1", 1);
        vm.warp(block.timestamp + 1);
        outpost.expirePayment(address(this), index);
        Outpost.Payment memory p = outpost.getPayment(address(this), index);
        assertEq(p.expired, true);
    }
}
