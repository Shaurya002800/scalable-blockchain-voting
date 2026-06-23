// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

interface ITallyProofVerifier {
    function verify(
        bytes calldata proof,
        bytes32 publicInputsHash
    ) external view returns (bool);
}

/// @notice Publishes a result only after a configured proof verifier accepts it.
/// @dev No verifier implementation is bundled yet. A proof hash alone is never
/// treated as verification.
contract TallyVerifier is Ownable {
    error InvalidResult();
    error VerifierNotConfigured();
    error ProofRejected();

    bytes32 public immutable electionId;
    ITallyProofVerifier public verifier;
    bytes32 public resultHash;
    bytes32 public publicInputsHash;
    bool public resultPublished;

    event VerifierUpdated(address indexed verifier);
    event TallyPublished(
        bytes32 indexed resultHash,
        bytes32 indexed publicInputsHash
    );

    constructor(
        bytes32 electionId_,
        address initialOwner,
        ITallyProofVerifier verifier_
    ) Ownable(initialOwner) {
        electionId = electionId_;
        verifier = verifier_;
    }

    function setVerifier(ITallyProofVerifier verifier_) external onlyOwner {
        verifier = verifier_;
        emit VerifierUpdated(address(verifier_));
    }

    function publishTally(
        bytes32 resultHash_,
        bytes32 publicInputsHash_,
        bytes calldata proof
    ) external onlyOwner {
        if (resultHash_ == bytes32(0) || publicInputsHash_ == bytes32(0)) {
            revert InvalidResult();
        }
        if (address(verifier) == address(0)) revert VerifierNotConfigured();
        if (!verifier.verify(proof, publicInputsHash_)) revert ProofRejected();

        resultHash = resultHash_;
        publicInputsHash = publicInputsHash_;
        resultPublished = true;

        emit TallyPublished(resultHash_, publicInputsHash_);
    }
}
