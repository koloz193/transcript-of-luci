// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract TranscriptOfLuci is AccessControlUpgradeable, OwnableUpgradeable {
    bytes32 public constant COMMENTER_ROLE =
        bytes32(uint256(keccak256("COMMENTER_ROLE")) - 1);

    mapping(uint256 x => mapping(uint256 y => Comment[] comments))
        private comments;

    mapping(address nftContract => mapping(uint256 tokenId => Comment comment))
        private commentByNft;

    // Comment[] private rawComments;

    struct Coordinate {
        uint256 x;
        uint256 y;
    }

    struct Comment {
        address commenter;
        string comment;
        Coordinate coordinate;
    }

    constructor(bool _disableInitializer) {
        if (_disableInitializer) {
            _disableInitializers();
        }
    }

    function initialize(address _owner) external initializer {
        _grantRole(DEFAULT_ADMIN_ROLE, _owner);
        _transferOwnership(_owner);
    }

    function addComment(
        uint256 _x,
        uint256 _y,
        address _commenter,
        string calldata _comment
    ) external onlyRole(COMMENTER_ROLE) {
        Coordinate memory coord = Coordinate({x: _x, y: _y});

        Comment memory comment = Comment({
            commenter: _commenter,
            comment: _comment,
            coordinate: coord
        });

        _addComment(_x, _y, comment);
    }

    function addCommentForNft(
        uint256 _x,
        uint256 _y,
        address _commenter,
        string calldata _comment
    ) external onlyRole(COMMENTER_ROLE) {
        Coordinate memory coord = Coordinate({x: _x, y: _y});

        Comment memory comment = Comment({
            commenter: _commenter,
            comment: _comment,
            coordinate: coord
        });

        _addComment(_x, _y, comment);
    }

    function _addComment(
        uint256 _x,
        uint256 _y,
        Comment memory _comment
    ) internal {
        comments[_x][_y].push(_comment);
    }

    function _addCommentForNft(
        uint256 _x,
        uint256 _y,
        address _nftContract,
        uint256 _tokenId,
        Comment memory _comment
    ) internal {
        commentByNft[_nftContract][_tokenId] = _comment;
        comments[_x][_y].push(_comment);
    }
}
