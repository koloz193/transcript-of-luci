// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

/*//////////////////////////////////////////////////////////////////////////
                                  Structs
//////////////////////////////////////////////////////////////////////////*/

struct Coordinate {
        uint256 x;
        uint256 y;
    }

    struct Comment {
        address commenter;
        string comment;
        Coordinate coordinate;
    }

contract TranscriptOfLuci is AccessControlUpgradeable, OwnableUpgradeable {
    /*//////////////////////////////////////////////////////////////////////////
                                  Constants
    //////////////////////////////////////////////////////////////////////////*/

    bytes32 public constant COMMENTER_ROLE =
        bytes32(uint256(keccak256("COMMENTER_ROLE")) - 1);

    /*//////////////////////////////////////////////////////////////////////////
                            Private Storage Variables
    //////////////////////////////////////////////////////////////////////////*/

    mapping(uint256 x => mapping(uint256 y => uint256[] commentIndexes))
        private comments;

    mapping(address nftContract => mapping(uint256 tokenId => uint256 commentIndex))
        private commentByNft;

    Comment[] private rawComments;

    /*//////////////////////////////////////////////////////////////////////////
                                  Constructor
    //////////////////////////////////////////////////////////////////////////*/

    constructor(bool _disableInitializer) {
        if (_disableInitializer) {
            _disableInitializers();
        }
    }

    /*//////////////////////////////////////////////////////////////////////////
                                  Initializer
    //////////////////////////////////////////////////////////////////////////*/

    function initialize(address _owner) external initializer {
        _grantRole(DEFAULT_ADMIN_ROLE, _owner);
        _transferOwnership(_owner);

        Comment memory empty;

        rawComments.push(empty);
    }

    /*//////////////////////////////////////////////////////////////////////////
                            Add Comments Functions
    //////////////////////////////////////////////////////////////////////////*/

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
        string calldata _comment,
        address _nftAddress,
        uint256 _tokenId
    ) external onlyRole(COMMENTER_ROLE) {
        Coordinate memory coord = Coordinate({x: _x, y: _y});

        Comment memory comment = Comment({
            commenter: _commenter,
            comment: _comment,
            coordinate: coord
        });

        _addCommentForNft(_x, _y, _nftAddress, _tokenId, comment);
    }

    function batchAddComments(
        uint256[] calldata _xs,
        uint256[] calldata _ys,
        address[] calldata _commenters,
        string[] calldata _comments
    ) external onlyRole(COMMENTER_ROLE) {
        for (uint256 i = 0; i < _xs.length; ++i) {
            Coordinate memory coord = Coordinate({x: _xs[i], y: _ys[i]});

            Comment memory comment = Comment({
                commenter: _commenters[i],
                comment: _comments[i],
                coordinate: coord
            });

            _addComment(_xs[i], _ys[i], comment);
        }
    }

    function batchAddCommentsForNfts(
        uint256[] calldata _xs,
        uint256[] calldata _ys,
        address[] calldata _commenters,
        string[] calldata _comments,
        address[] calldata _nftAddresses,
        uint256[] calldata _tokenIds
    ) external onlyRole(COMMENTER_ROLE) {
        for (uint256 i = 0; i < _xs.length; ++i) {
            Coordinate memory coord = Coordinate({x: _xs[i], y: _ys[i]});

            Comment memory comment = Comment({
                commenter: _commenters[i],
                comment: _comments[i],
                coordinate: coord
            });

            _addCommentForNft(_xs[i], _ys[i], _nftAddresses[i], _tokenIds[i], comment);
        }
    }

    /*//////////////////////////////////////////////////////////////////////////
                            Get Comments Functions
    //////////////////////////////////////////////////////////////////////////*/

    function getCommentForCoordinates(
        uint256 _x,
        uint256 _y
    ) external view returns (Comment[] memory commentsForCoordinate) {
        uint256[] storage indices = comments[_x][_y];
        uint256 numComments = indices.length;

        commentsForCoordinate = new Comment[](numComments);

        for (uint256 i = 0; i < numComments; ++i) {
            uint256 index = indices[i];
            commentsForCoordinate[i] = rawComments[index];
        }
    }

    function getCommentForNft(
        address _nftContract,
        uint256 _tokenId
    ) external view returns (Comment memory) {
        uint256 index = commentByNft[_nftContract][_tokenId];
        return rawComments[index];
    }

    /*//////////////////////////////////////////////////////////////////////////
                                Internal Functions
    //////////////////////////////////////////////////////////////////////////*/

    function _addComment(
        uint256 _x,
        uint256 _y,
        Comment memory _comment
    ) internal {
        rawComments.push(_comment);
        uint256 index = rawComments.length - 1;
        comments[_x][_y].push(index);
    }

    function _addCommentForNft(
        uint256 _x,
        uint256 _y,
        address _nftContract,
        uint256 _tokenId,
        Comment memory _comment
    ) internal {
        rawComments.push(_comment);
        uint256 index = rawComments.length - 1;

        commentByNft[_nftContract][_tokenId] = index;
        comments[_x][_y].push(index);
    }
}
