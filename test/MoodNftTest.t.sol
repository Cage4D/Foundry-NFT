// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {MoodNft} from "../src/MoodNft.sol";
import {DeployMoodNft} from "../script/DeployMoodNft.s.sol";

contract MoodNftTest is Test {
    MoodNft moodNft;
    DeployMoodNft deployer;
    address USER = makeAddr("user");
    address OTHER = makeAddr("other");

    string happySvgUri;
    string sadSvgUri;

    function setUp() public {
        deployer = new DeployMoodNft();
        happySvgUri = deployer.svgToImageURI(vm.readFile("./img/happy.svg"));
        sadSvgUri = deployer.svgToImageURI(vm.readFile("./img/sad.svg"));
        // Constructor order is (sad, happy)
        moodNft = new MoodNft(sadSvgUri, happySvgUri);
    }

    function _expectedTokenUri(string memory imageUri) internal view returns (string memory) {
        string memory json = string.concat(
            '{"name":"',
            moodNft.name(),
            '", "description":"An NFT that reflects the mood of the owner, 100% on Chain!", ',
            '"attributes": [{"trait_type": "moodiness", "value": 100}], "image":"',
            imageUri,
            '"}'
        );
        return string.concat("data:application/json;base64,", vm.toBase64(json));
    }

    function testMintSetsOwnerAndCounter() public {
        vm.prank(USER);
        moodNft.mintNft();
        assertEq(moodNft.ownerOf(0), USER);
        assertEq(moodNft.balanceOf(USER), 1);
        assertEq(moodNft.getTokenCounter(), 1);
    }

    function testNewMintIsHappy() public {
        vm.prank(USER);
        moodNft.mintNft();
        assertEq(uint256(moodNft.getMood(0)), uint256(MoodNft.Mood.HAPPY));
        assertEq(moodNft.tokenURI(0), _expectedTokenUri(happySvgUri));
    }

    function testFlipMoodToSad() public {
        vm.startPrank(USER);
        moodNft.mintNft();
        moodNft.flipMood(0);
        vm.stopPrank();
        assertEq(uint256(moodNft.getMood(0)), uint256(MoodNft.Mood.SAD));
        assertEq(moodNft.tokenURI(0), _expectedTokenUri(sadSvgUri));
    }

    function testFlipTwiceIsHappyAgain() public {
        vm.startPrank(USER);
        moodNft.mintNft();
        moodNft.flipMood(0);
        moodNft.flipMood(0);
        vm.stopPrank();
        assertEq(moodNft.tokenURI(0), _expectedTokenUri(happySvgUri));
    }

    function testTokenUriUsesEachTokensOwnMood() public {
        vm.prank(USER);
        moodNft.mintNft(); // token 0
        vm.prank(OTHER);
        moodNft.mintNft(); // token 1
        vm.prank(USER);
        moodNft.flipMood(0);
        assertEq(moodNft.tokenURI(0), _expectedTokenUri(sadSvgUri));
        assertEq(moodNft.tokenURI(1), _expectedTokenUri(happySvgUri));
    }

    function testNonOwnerCantFlipMood() public {
        vm.prank(USER);
        moodNft.mintNft();
        vm.prank(OTHER);
        vm.expectRevert(MoodNft.MoodNft__CantFlipMoodIfNotOwner.selector);
        moodNft.flipMood(0);
    }

    function testApprovedCanFlipMood() public {
        vm.startPrank(USER);
        moodNft.mintNft();
        moodNft.approve(OTHER, 0);
        vm.stopPrank();
        vm.prank(OTHER);
        moodNft.flipMood(0);
        assertEq(uint256(moodNft.getMood(0)), uint256(MoodNft.Mood.SAD));
    }

    function testTokenUriRevertsForNonexistentToken() public {
        vm.expectRevert();
        moodNft.tokenURI(0);
    }
}
