// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @notice Append-only trusted-demo batch commitments.
/// @dev Root submission is not a batch-validity proof. The authorized batcher
/// remains trusted until a verifier for ballot validity and state transition
/// is integrated.
contract BatchCommitment is Ownable {
    error InvalidBatch();
    error UnauthorizedBatcher(address caller);
    error NullifierRootMismatch(
        bytes32 expectedPreviousRoot,
        bytes32 suppliedPreviousRoot
    );
    error RootAlreadyCommitted(bytes32 cidMerkleRoot);

    struct Batch {
        bytes32 cidMerkleRoot;
        bytes32 previousNullifierRoot;
        bytes32 nullifierRoot;
        bytes32 manifestDigest;
        uint64 batchSize;
        uint64 submittedAt;
        address batcher;
    }

    bytes32 public immutable electionId;
    bytes32 public latestNullifierRoot;
    uint256 public batchCount;

    mapping(address batcher => bool authorized) public isBatcher;
    mapping(bytes32 cidMerkleRoot => bool committed) public isRootCommitted;
    mapping(uint256 batchIndex => Batch batch) private batches;

    event BatcherAuthorizationChanged(
        address indexed batcher,
        bool authorized
    );
    event BatchCommitted(
        uint256 indexed batchIndex,
        bytes32 indexed cidMerkleRoot,
        bytes32 previousNullifierRoot,
        bytes32 nullifierRoot,
        bytes32 manifestDigest,
        uint64 batchSize,
        address indexed batcher
    );

    constructor(
        bytes32 electionId_,
        address initialOwner,
        address initialBatcher
    ) Ownable(initialOwner) {
        electionId = electionId_;
        _setBatcher(initialBatcher, true);
    }

    function setBatcher(address batcher, bool authorized) external onlyOwner {
        _setBatcher(batcher, authorized);
    }

    function submitBatch(
        bytes32 cidMerkleRoot,
        bytes32 previousNullifierRoot,
        bytes32 nullifierRoot,
        bytes32 manifestDigest,
        uint64 batchSize
    ) external returns (uint256 batchIndex) {
        if (!isBatcher[msg.sender]) revert UnauthorizedBatcher(msg.sender);
        if (
            cidMerkleRoot == bytes32(0) ||
            nullifierRoot == bytes32(0) ||
            manifestDigest == bytes32(0) ||
            batchSize == 0
        ) revert InvalidBatch();
        if (previousNullifierRoot != latestNullifierRoot) {
            revert NullifierRootMismatch(
                latestNullifierRoot,
                previousNullifierRoot
            );
        }
        if (isRootCommitted[cidMerkleRoot]) {
            revert RootAlreadyCommitted(cidMerkleRoot);
        }

        batchIndex = batchCount;
        batches[batchIndex] = Batch({
            cidMerkleRoot: cidMerkleRoot,
            previousNullifierRoot: previousNullifierRoot,
            nullifierRoot: nullifierRoot,
            manifestDigest: manifestDigest,
            batchSize: batchSize,
            submittedAt: uint64(block.timestamp),
            batcher: msg.sender
        });

        batchCount = batchIndex + 1;
        latestNullifierRoot = nullifierRoot;
        isRootCommitted[cidMerkleRoot] = true;

        emit BatchCommitted(
            batchIndex,
            cidMerkleRoot,
            previousNullifierRoot,
            nullifierRoot,
            manifestDigest,
            batchSize,
            msg.sender
        );
    }

    function getBatch(uint256 batchIndex)
        external
        view
        returns (Batch memory)
    {
        return batches[batchIndex];
    }

    function _setBatcher(address batcher, bool authorized) private {
        if (batcher == address(0)) revert UnauthorizedBatcher(batcher);
        isBatcher[batcher] = authorized;
        emit BatcherAuthorizationChanged(batcher, authorized);
    }
}
