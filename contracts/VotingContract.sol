// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {VoterRegistry} from "./VoterRegistry.sol";

/// @notice Direct ballot-commitment path used for local contract testing.
/// @dev The scalable demo path will commit batches instead of one transaction
/// per ballot.
contract VotingContract {
    error InvalidDigest();
    error NullifierAlreadyUsed(bytes32 ballotNullifier);
    error UnauthorizedVotingKey();

    bytes32 public immutable electionId;
    VoterRegistry public immutable voterRegistry;

    mapping(bytes32 ballotNullifier => bool used) public isNullifierUsed;

    event BallotCommitted(
        bytes32 indexed ballotNullifier,
        bytes32 indexed identityNullifier,
        bytes32 votePackageDigest
    );

    constructor(bytes32 electionId_, VoterRegistry voterRegistry_) {
        electionId = electionId_;
        voterRegistry = voterRegistry_;
    }

    function submitBallot(
        bytes32 identityNullifier,
        bytes32 ballotNullifier,
        bytes32 votePackageDigest
    ) external {
        if (votePackageDigest == bytes32(0)) revert InvalidDigest();
        if (isNullifierUsed[ballotNullifier]) {
            revert NullifierAlreadyUsed(ballotNullifier);
        }
        if (voterRegistry.votingKeyOf(identityNullifier) != msg.sender) {
            revert UnauthorizedVotingKey();
        }

        isNullifierUsed[ballotNullifier] = true;
        emit BallotCommitted(
            ballotNullifier,
            identityNullifier,
            votePackageDigest
        );
    }
}
