// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/// @notice Immutable public parameters for one demo election.
contract ElectionConfig {
    error InvalidVotingWindow();
    error InvalidConfiguration();

    bytes32 public immutable electionId;
    bytes32 public immutable candidateListHash;
    bytes32 public immutable electionPublicKeyHash;
    uint64 public immutable votingStartsAt;
    uint64 public immutable votingEndsAt;

    constructor(
        bytes32 electionId_,
        bytes32 candidateListHash_,
        bytes32 electionPublicKeyHash_,
        uint64 votingStartsAt_,
        uint64 votingEndsAt_
    ) {
        if (
            electionId_ == bytes32(0) ||
            candidateListHash_ == bytes32(0) ||
            electionPublicKeyHash_ == bytes32(0)
        ) revert InvalidConfiguration();
        if (
            votingStartsAt_ >= votingEndsAt_ ||
            votingEndsAt_ <= block.timestamp
        ) revert InvalidVotingWindow();

        electionId = electionId_;
        candidateListHash = candidateListHash_;
        electionPublicKeyHash = electionPublicKeyHash_;
        votingStartsAt = votingStartsAt_;
        votingEndsAt = votingEndsAt_;
    }
}
