// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import {Vm} from "forge-std/Vm.sol";
import {DSTest} from "ds-test/test.sol";
import {Semaphore} from "./mock/Semaphore.sol";
import {TestERC20} from "./mock/TestERC20.sol";
import {SemaphoreAirdrop} from "../SemaphoreAirdrop.sol";

contract User {}

contract SemaphoreAirdropTest is DSTest {
    event AmountUpdated(uint256 amount);

    User internal user;
    TestERC20 internal token;
    Semaphore internal semaphore;
    SemaphoreAirdrop internal airdrop;
    Vm internal hevm = Vm(HEVM_ADDRESS);

    function setUp() public {
        user = new User();
        token = new TestERC20();
        semaphore = new Semaphore();
        airdrop = new SemaphoreAirdrop(
            semaphore,
            0,
            token,
            address(user),
            1 ether
        );

        // Issue some tokens to the user address, to be airdropped from the contract
        token.issue(address(user), 10 ether);

        // Approve spending from the airdrop contract
        hevm.prank(address(user));
        token.approve(address(airdrop), type(uint256).max);
    }

    function testUpdateAirdropAmount() public {
        assertEq(airdrop.airdropAmount(), 1 ether);

        hevm.expectEmit(false, false, false, true);
        emit AmountUpdated(2 ether);
        airdrop.updateAmount(2 ether);

        assertEq(airdrop.airdropAmount(), 2 ether);
    }

    function testCannotUpdateAirdropAmountIfNotManager() public {
        assertEq(airdrop.airdropAmount(), 1 ether);

        hevm.expectRevert(SemaphoreAirdrop.Unauthorized.selector);
        hevm.prank(address(user));
        airdrop.updateAmount(2 ether);

        assertEq(airdrop.airdropAmount(), 1 ether);
    }
}