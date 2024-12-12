// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {TranscriptOfLuci, Comment} from "../src/TranscriptOfLuci.sol";

contract TranscriptOfLuciTest is Test {
    TranscriptOfLuci public transcript;
    address public alice;
    address public bob;
    address public charles;
    address public nft;
    address public base;
    uint256 public tokenId;

    function setUp() public {
        alice = makeAddr("alice");
        bob = makeAddr("bob");
        charles = makeAddr("charles");
        nft = makeAddr("nft");
        base = makeAddr("base");

        tokenId = uint256(keccak256("TOKEN_ID"));

        transcript = new TranscriptOfLuci(false);
        transcript.initialize(alice);

        vm.startPrank(alice);
        transcript.grantRole(transcript.COMMENTER_ROLE(), bob);
        vm.stopPrank();
    }

    function test_addComment() public {
        vm.prank(bob);
        transcript.addComment(base, tokenId, 4720423717920495500000000, 3063794169465206600000000, charles, "Does anything truly exist beyond our own mind? We see only what our mind allows, the picture through the foggy lens of fear and hope. I see the best of me, building the temple of a better world, lending a hand to those that still cling to solid ground for fear to Wander the unknown. I see the worst of me, the masks I wear, the moments where I'm raw and cruel and push others away. And all the while she holds me at the edge, I feel her hand in mine, and I see not what I am, but the best that I can be.");

        Comment[] memory comments = transcript.getCommentForCoordinates(base, tokenId, 4720423717920495500000000, 3063794169465206600000000);
        assertEq(comments.length, 1, "comment length");

        console.log(comments[0].commenter);
        console.log(comments[0].comment);
        console.log(comments[0].coordinate.x);
        console.log(comments[0].coordinate.y);
    }

    function test_addCommentForNft() public {
        vm.prank(bob);
        transcript.addCommentForNft(base, tokenId, 420, 120, alice, "hello again, world!", nft, 1);

        Comment memory comment = transcript.getCommentForNft(nft, 1);
        console.log(comment.commenter);
        console.log(comment.comment);
        console.log(comment.coordinate.x);
        console.log(comment.coordinate.y);
    }

    function test_addMultipleComments() public {
        vm.startPrank(bob);
        transcript.addComment(base, tokenId, 120, 420, charles, "hello, world!");
        transcript.addComment(base, tokenId, 120, 420, alice, "im here too!");
        vm.stopPrank();

        Comment[] memory comments = transcript.getCommentForCoordinates(base, tokenId, 120, 420);
        assertEq(comments.length, 2, "comment length");

        console.log(comments[0].commenter);
        console.log(comments[0].comment);
        console.log(comments[0].coordinate.x);
        console.log(comments[0].coordinate.y);
        console.log();
        console.log(comments[1].commenter);
        console.log(comments[1].comment);
        console.log(comments[1].coordinate.x);
        console.log(comments[1].coordinate.y);
    }

    function test_batchAddCommentsSameCoordinate() public {
        uint256[] memory xs = new uint256[](2);
        xs[0] = 120;
        xs[1] = 120;

        uint256[] memory ys = new uint256[](2);
        ys[0] = 420;
        ys[1] = 420;

        address[] memory commenters = new address[](2);
        commenters[0] = charles;
        commenters[1] = alice;

        string[] memory messages = new string[](2);
        messages[0] = "hello, world!";
        messages[1] = "im here too!";

        vm.startPrank(bob);
        transcript.batchAddComments(base, tokenId, xs, ys, commenters, messages);
        vm.stopPrank();

        Comment[] memory comments = transcript.getCommentForCoordinates(base, tokenId, 120, 420);
        assertEq(comments.length, 2, "comment length");

        console.log(comments[0].commenter);
        console.log(comments[0].comment);
        console.log(comments[0].coordinate.x);
        console.log(comments[0].coordinate.y);
        console.log();
        console.log(comments[1].commenter);
        console.log(comments[1].comment);
        console.log(comments[1].coordinate.x);
        console.log(comments[1].coordinate.y);
    }

    function test_batchAddCommentsDiffCoordinate() public {
        uint256[] memory xs = new uint256[](2);
        xs[0] = 120;
        xs[1] = 420;

        uint256[] memory ys = new uint256[](2);
        ys[0] = 420;
        ys[1] = 120;

        address[] memory commenters = new address[](2);
        commenters[0] = charles;
        commenters[1] = alice;

        string[] memory messages = new string[](2);
        messages[0] = "hello, world!";
        messages[1] = "im here too!";

        vm.startPrank(bob);
        transcript.batchAddComments(base, tokenId, xs, ys, commenters, messages);
        vm.stopPrank();

        Comment[] memory comments = transcript.getCommentForCoordinates(base, tokenId, 120, 420);
        assertEq(comments.length, 1, "comment length");

        console.log(comments[0].commenter);
        console.log(comments[0].comment);
        console.log(comments[0].coordinate.x);
        console.log(comments[0].coordinate.y);
        console.log();

        comments = transcript.getCommentForCoordinates(base, tokenId, 420, 120);
        assertEq(comments.length, 1, "comment length");

        console.log(comments[0].commenter);
        console.log(comments[0].comment);
        console.log(comments[0].coordinate.x);
        console.log(comments[0].coordinate.y);
    }

    function test_batchAddCommentsForNftsSameCoordinate() public {
        uint256[] memory xs = new uint256[](2);
        xs[0] = 120;
        xs[1] = 120;

        uint256[] memory ys = new uint256[](2);
        ys[0] = 420;
        ys[1] = 420;

        address[] memory commenters = new address[](2);
        commenters[0] = charles;
        commenters[1] = alice;

        string[] memory messages = new string[](2);
        messages[0] = "hello, world!";
        messages[1] = "im here too!";

        address[] memory nftContracts = new address[](2);
        nftContracts[0] = nft;
        nftContracts[1] = nft;

        uint256[] memory tokenIds = new uint256[](2);
        tokenIds[0] = 1;
        tokenIds[1] = 2;

        vm.startPrank(bob);
        transcript.batchAddCommentsForNfts(base, tokenId, xs, ys, commenters, messages, nftContracts, tokenIds);
        vm.stopPrank();

        Comment[] memory comments = transcript.getCommentForCoordinates(base, tokenId, 120, 420);
        assertEq(comments.length, 2, "comment length");

        console.log(comments[0].commenter);
        console.log(comments[0].comment);
        console.log(comments[0].coordinate.x);
        console.log(comments[0].coordinate.y);
        console.log();
        console.log(comments[1].commenter);
        console.log(comments[1].comment);
        console.log(comments[1].coordinate.x);
        console.log(comments[1].coordinate.y);
        console.log();

        Comment memory comment = transcript.getCommentForNft(nft, 1);
        console.log(comment.commenter);
        console.log(comment.comment);
        console.log(comment.coordinate.x);
        console.log(comment.coordinate.y);
        console.log();
        comment = transcript.getCommentForNft(nft, 2);
        console.log(comment.commenter);
        console.log(comment.comment);
        console.log(comment.coordinate.x);
        console.log(comment.coordinate.y);
    }

    function test_batchAddCommentsForNftsDiffCoordinate() public {
        uint256[] memory xs = new uint256[](2);
        xs[0] = 120;
        xs[1] = 420;

        uint256[] memory ys = new uint256[](2);
        ys[0] = 420;
        ys[1] = 120;

        address[] memory commenters = new address[](2);
        commenters[0] = charles;
        commenters[1] = alice;

        string[] memory messages = new string[](2);
        messages[0] = "hello, world!";
        messages[1] = "im here too!";

       address[] memory nftContracts = new address[](2);
        nftContracts[0] = nft;
        nftContracts[1] = nft;

        uint256[] memory tokenIds = new uint256[](2);
        tokenIds[0] = 1;
        tokenIds[1] = 2;

        vm.startPrank(bob);
        transcript.batchAddCommentsForNfts(base, tokenId, xs, ys, commenters, messages, nftContracts, tokenIds);
        vm.stopPrank();

        Comment[] memory comments = transcript.getCommentForCoordinates(base, tokenId, 120, 420);
        assertEq(comments.length, 1, "comment length");

        console.log(comments[0].commenter);
        console.log(comments[0].comment);
        console.log(comments[0].coordinate.x);
        console.log(comments[0].coordinate.y);
        console.log();

        comments = transcript.getCommentForCoordinates(base, tokenId, 420, 120);
        assertEq(comments.length, 1, "comment length");

        console.log(comments[0].commenter);
        console.log(comments[0].comment);
        console.log(comments[0].coordinate.x);
        console.log(comments[0].coordinate.y);
        console.log();

        Comment memory comment = transcript.getCommentForNft(nft, 1);
        console.log(comment.commenter);
        console.log(comment.comment);
        console.log(comment.coordinate.x);
        console.log(comment.coordinate.y);
        console.log();
        comment = transcript.getCommentForNft(nft, 2);
        console.log(comment.commenter);
        console.log(comment.comment);
        console.log(comment.coordinate.x);
        console.log(comment.coordinate.y);
    }
}
