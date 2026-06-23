// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @notice Trusted registration seam for the first testnet demo.
/// @dev Replace the owner-only path with anonymous eligibility-proof
/// verification before making stronger security claims.
contract VoterRegistry is Ownable {
    error IdentityAlreadyRegistered(bytes32 identityNullifier);
    error VotingKeyAlreadyRegistered(address votingKey);
    error InvalidVotingKey();
    error UnknownIdentity(bytes32 identityNullifier);

    bytes32 public immutable electionId;

    mapping(bytes32 identityNullifier => address votingKey)
        private votingKeys;
    mapping(address votingKey => bool registered) public isVotingKeyRegistered;

    event VoterRegistered(
        bytes32 indexed identityNullifier,
        address indexed votingKey
    );

    constructor(bytes32 electionId_, address initialOwner)
        Ownable(initialOwner)
    {
        electionId = electionId_;
    }

    function register(
        bytes32 identityNullifier,
        address votingKey
    ) external onlyOwner {
        if (votingKey == address(0)) revert InvalidVotingKey();
        if (votingKeys[identityNullifier] != address(0)) {
            revert IdentityAlreadyRegistered(identityNullifier);
        }
        if (isVotingKeyRegistered[votingKey]) {
            revert VotingKeyAlreadyRegistered(votingKey);
        }

        votingKeys[identityNullifier] = votingKey;
        isVotingKeyRegistered[votingKey] = true;

        emit VoterRegistered(identityNullifier, votingKey);
    }

    function votingKeyOf(
        bytes32 identityNullifier
    ) external view returns (address) {
        address votingKey = votingKeys[identityNullifier];
        if (votingKey == address(0)) {
            revert UnknownIdentity(identityNullifier);
        }
        return votingKey;
    }
}
