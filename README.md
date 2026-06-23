# Scalable Blockchain Voting

Zero-cost testnet demonstration of a privacy-preserving voting pipeline using
election-scoped identities, encrypted ballot packages, batch commitments, and
verifiable tally publication.

## Current status

This repository is at the contract-foundation stage. It includes:

- a Hardhat 3 + TypeScript development environment;
- immutable election configuration;
- trusted-demo voter registration using election-scoped nullifiers and
  ephemeral voting addresses;
- a direct ballot-commitment path for local contract testing;
- append-only batch commitments with nullifier-root continuity; and
- a tally-verifier adapter that requires a real verifier contract before a
  result can be marked verified.

The biometric screen, Anon Aadhaar integration, ballot and tally circuits,
IPFS storage, ERC-4337 sponsorship, threshold decryption, and frontend are not
implemented yet.

## Important security boundary

The current batch contract records roots; it does not prove that every ballot
inside a batch is valid or available. Until a batch-validity and
nullifier-state proof is implemented, the batcher is trusted and the project
must be presented as a testnet demonstration—not a production election
system.

## Requirements

- Node.js 22.13 or newer
- npm 10 or newer

## Setup

```bash
npm install
cp .env.example .env
npm run compile
npm test
```

Local deployment:

```bash
npm run deploy:local
```

Polygon Amoy deployment:

```bash
npm run deploy:amoy
```

Amoy uses chain ID `80002` and POL as its gas token.

## Repository layout

```text
contracts/   Solidity contracts and verifier interfaces
ignition/    Repeatable deployment modules
test/        Contract tests
circuits/    Future Circom circuits
packages/    Future shared cryptography and Merkle utilities
frontend/    Future Next.js application
docs/        Architecture, scope, and implementation roadmap
```

See [docs/architecture.md](docs/architecture.md) for trust boundaries and
[docs/implementation-roadmap.md](docs/implementation-roadmap.md) for the next
build milestones.
