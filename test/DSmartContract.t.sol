// SPDX-License-Identifier:MIT

pragma solidity ^0.8.20;

import {Test} from "../lib/forge-std/src/Test.sol";
import {console} from "../lib/forge-std/src/console.sol";
import {DSmartContract} from "../src/DSmartContract.sol";

contract DSmartContractTest is Test {
    DSmartContract public dSmartContract;

    function setUp() public {
        dSmartContract = new DSmartContract();
    }

    function test_addMember() public {
        vm.startPrank(0xD79a0889091D0c2a29A4Dc2f395a0108c69820Cf);
        setUp();
        dSmartContract.addMember();
        assertEq(
            dSmartContract.isMember(0xD79a0889091D0c2a29A4Dc2f395a0108c69820Cf),
            true
        );
        vm.stopPrank();
    }

    function test_createProposal() public {
        vm.startPrank(0xD79a0889091D0c2a29A4Dc2f395a0108c69820Cf);
        setUp();
        dSmartContract.addMember();
        assertEq(
            dSmartContract.isMember(0xD79a0889091D0c2a29A4Dc2f395a0108c69820Cf),
            true
        );
        dSmartContract.createProposal("My first proposal", 120, 1, 20);
        assertEq(dSmartContract.isProposal(1), true);
        vm.stopPrank();
    }

    function test_removeMember() public {
        setUp();
        vm.startPrank(0xD79a0889091D0c2a29A4Dc2f395a0108c69820Cf);
        dSmartContract.addMember();
        assertEq(
            dSmartContract.isMember(0xD79a0889091D0c2a29A4Dc2f395a0108c69820Cf),
            true
        );
        vm.stopPrank();

        vm.startPrank(0x04c1A796D9049ce70c2B4A188Ae441c4c619983c);
        dSmartContract.addMember();
        assertEq(
            dSmartContract.isMember(0x04c1A796D9049ce70c2B4A188Ae441c4c619983c),
            true
        );
        vm.stopPrank();

        vm.startPrank(0xD79a0889091D0c2a29A4Dc2f395a0108c69820Cf);
        dSmartContract.removeMember(0x04c1A796D9049ce70c2B4A188Ae441c4c619983c);
        assertEq(
            dSmartContract.isMember(0x04c1A796D9049ce70c2B4A188Ae441c4c619983c),
            false
        );
        vm.stopPrank();
    }

    function test_voteProposal() public {
        vm.startPrank(0xD79a0889091D0c2a29A4Dc2f395a0108c69820Cf);
        setUp();
        dSmartContract.addMember();
        assertEq(
            dSmartContract.isMember(0xD79a0889091D0c2a29A4Dc2f395a0108c69820Cf),
            true
        );
        vm.startPrank(0x04c1A796D9049ce70c2B4A188Ae441c4c619983c);
        dSmartContract.addMember();
        assertEq(
            dSmartContract.isMember(0x04c1A796D9049ce70c2B4A188Ae441c4c619983c),
            true
        );
        dSmartContract.createProposal("My first proposal", 120, 1, 20);
        assertEq(dSmartContract.isProposal(1), true);
        vm.stopPrank();
    }

    function test_executeProposal() public {
        setUp();
        vm.startPrank(0xD79a0889091D0c2a29A4Dc2f395a0108c69820Cf);
        // setUp();
        dSmartContract.addMember();
        assertEq(
            dSmartContract.isMember(0xD79a0889091D0c2a29A4Dc2f395a0108c69820Cf),
            true
        );

        dSmartContract.createProposal("My first proposal", 240, 1, 20);
        assertEq(dSmartContract.isProposal(1), true);

        assertEq(
            dSmartContract.memberHasVotedOrNot(
                1,
                0xD79a0889091D0c2a29A4Dc2f395a0108c69820Cf
            ),
            true
        );

        vm.stopPrank();

        vm.startPrank(0x04c1A796D9049ce70c2B4A188Ae441c4c619983c);

        dSmartContract.addMember();
        assertEq(
            dSmartContract.isMember(0x04c1A796D9049ce70c2B4A188Ae441c4c619983c),
            true
        );

        dSmartContract.voteProposal(1, 2);

        assertEq(
            dSmartContract.memberHasVotedOrNot(
                1,
                0x04c1A796D9049ce70c2B4A188Ae441c4c619983c
            ),
            true
        );

        vm.warp(block.timestamp + 250);
        dSmartContract.executeProposal(1);
        assertEq(dSmartContract.checkExecutedOrNot(1), true);

        vm.stopPrank();
    }

    function test_challengeProposal() public {
        setUp();
        vm.startPrank(0xD79a0889091D0c2a29A4Dc2f395a0108c69820Cf);
        dSmartContract.addMember();
        dSmartContract.createProposal("My new proposal", 240, 1, 20);
        vm.warp(block.timestamp + 250);
        dSmartContract.executeProposal(1);
        assertEq(dSmartContract.checkExecutedOrNot(1), true);
        dSmartContract.challengingProposal("It's a proposal", 1);
        assertEq(dSmartContract.checkExecutedOrNot(1), false);
        vm.stopPrank();
    }

    function testFail_addMember() public {
        vm.startPrank(0xD79a0889091D0c2a29A4Dc2f395a0108c69820Cf);
        setUp();
        dSmartContract.addMember();
        assertEq(
            dSmartContract.isMember(0xD79a0889091D0c2a29A4Dc2f395a0108c69820Cf),
            false
        );
        vm.stopPrank();
    }

    function testFail_createProposal() public {
        vm.startPrank(0xD79a0889091D0c2a29A4Dc2f395a0108c69820Cf);
        setUp();
        dSmartContract.addMember();
        assertEq(
            dSmartContract.isMember(0xD79a0889091D0c2a29A4Dc2f395a0108c69820Cf),
            true
        );

        dSmartContract.createProposal("My second proposal", 240, 1, 20);
        assertEq(dSmartContract.isProposal(1), false);
        vm.stopPrank();
    }

    function testFail_removeMember() public {
        setUp();
        vm.startPrank(0xD79a0889091D0c2a29A4Dc2f395a0108c69820Cf);
        dSmartContract.addMember();
        assertEq(
            dSmartContract.isMember(0xD79a0889091D0c2a29A4Dc2f395a0108c69820Cf),
            false
        );
        vm.stopPrank();

        vm.startPrank(0x04c1A796D9049ce70c2B4A188Ae441c4c619983c);
        dSmartContract.addMember();
        assertEq(
            dSmartContract.isMember(0x04c1A796D9049ce70c2B4A188Ae441c4c619983c),
            false
        );

        dSmartContract.removeMember(0x04c1A796D9049ce70c2B4A188Ae441c4c619983c);
        assertEq(
            dSmartContract.isMember(0x04c1A796D9049ce70c2B4A188Ae441c4c619983c),
            true
        );
        vm.stopPrank();
    }

    function testFail_voteProposal() public {
        setUp();
        vm.startPrank(0xD79a0889091D0c2a29A4Dc2f395a0108c69820Cf);
        dSmartContract.addMember();
        assertEq(
            dSmartContract.isMember(0xD79a0889091D0c2a29A4Dc2f395a0108c69820Cf),
            true
        );

        dSmartContract.createProposal("My new testFail proposal", 240, 1, 20);
        vm.stopPrank();

        vm.startPrank(0x04c1A796D9049ce70c2B4A188Ae441c4c619983c);
        dSmartContract.voteProposal(0, 2);
        assertEq(
            dSmartContract.memberHasVotedOrNot(
                0,
                0x04c1A796D9049ce70c2B4A188Ae441c4c619983c
            ),
            false
        );
    }
    function testFail_executeProposal() public {
        setUp();
        vm.startPrank(0xD79a0889091D0c2a29A4Dc2f395a0108c69820Cf);
        dSmartContract.addMember();
        assertEq(
            dSmartContract.isMember(0xD79a0889091D0c2a29A4Dc2f395a0108c69820Cf),
            true
        );

        dSmartContract.createProposal("My new proposal", 240, 1, 20);
        assertEq(dSmartContract.isProposal(1), true);

        vm.stopPrank();

        vm.startPrank(0x04c1A796D9049ce70c2B4A188Ae441c4c619983c);
        dSmartContract.addMember();
        assertEq(
            dSmartContract.isMember(0x04c1A796D9049ce70c2B4A188Ae441c4c619983c),
            true
        );

        dSmartContract.voteProposal(0, 2);

        assertEq(
            dSmartContract.memberHasVotedOrNot(
                0,
                0x04c1A796D9049ce70c2B4A188Ae441c4c619983c
            ),
            true
        );

        vm.warp(block.timestamp + 250);

        dSmartContract.executeProposal(0);
        assertEq(dSmartContract.checkExecutedOrNot(0), false);
        vm.stopPrank();
    }

    function testFail_challengeProposal() public {
        setUp();
        vm.startPrank(0xD79a0889091D0c2a29A4Dc2f395a0108c69820Cf);
        dSmartContract.addMember();
        dSmartContract.createProposal("My new proposal", 240, 1, 20);
        vm.warp(block.timestamp + 250);
        dSmartContract.executeProposal(1);
        assertEq(dSmartContract.checkExecutedOrNot(1), true);
        vm.stopPrank();
        vm.startPrank(0x04c1A796D9049ce70c2B4A188Ae441c4c619983c);
        dSmartContract.challengingProposal("It's a proposal", 1);
        assertEq(dSmartContract.checkExecutedOrNot(1), false);
        vm.stopPrank();
    }
}
