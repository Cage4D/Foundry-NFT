// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {MoodNft} from "../src/MoodNft.sol";
import {DeployMoodNft} from "../script/DeployMoodNft.s.sol";

contract MoodNftIntegrationTest is Test {
    MoodNft moodNft;
    DeployMoodNft deployer;
    address USER = makeAddr("user");

    function setUp() public {
        deployer = new DeployMoodNft();
        moodNft = deployer.run();
    }

    function testDeployedNameAndSymbol() public view {
        assertEq(moodNft.name(), "Mood NFT");
        assertEq(moodNft.symbol(), "MN");
    }

    function testFlipChangesTokenUri() public {
        vm.startPrank(USER);
        moodNft.mintNft();
        string memory happyUri = moodNft.tokenURI(0);
        moodNft.flipMood(0);
        string memory sadUri = moodNft.tokenURI(0);
        vm.stopPrank();
        assertTrue(keccak256(bytes(happyUri)) != keccak256(bytes(sadUri)));
    }
}
