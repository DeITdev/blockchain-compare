# Code Standards

## General

- Keep modules small and single-purpose — one backend or one API concern per change.
- Fix root causes; do not layer workarounds over misconfigured ports or wrong RPC URLs.
- Do not mix unrelated concerns in one file (e.g. deploy logic inside route handlers).
- Match existing conventions in the reference repo when porting — root folders should read as if written by the same author.
- Prefer Docker Compose over platform-specific CLI instructions for cross-platform parity (Windows, macOS, Linux).

## Language and Runtime

| Area | Standard |
|------|----------|
| API and scripts | JavaScript, ES modules (`import`/`export`) |
| Smart contracts | Solidity `0.8.x`, `evmVersion: istanbul` |
| Fabric chaincode | Go (mirrors `{x}Storage` envelope fields) |
| Node.js | ≥ 22.10 for `API/` (match reference); ≥ 18 for sample app |
| Config | `.env` files; never commit secrets |

## Solidity and Hardhat

- Optimizer enabled: `{ enabled: true, runs: 200 }`.
- One `hardhat.config.js` with multiple network entries: `besu`, `geth`, `sepolia` (Fabric deploys outside Hardhat).
- Network config driven by env vars:

```javascript
// Pattern from reference hardhat.config.js
const rpcUrl = process.env.BESU_RPC_URL || "http://localhost:8545";
const chainId = Number(process.env.BESU_CHAIN_ID || 1337);
```

- Separate deploy scripts per target: `API/scripts/deploy-{besu,geth,sepolia,fabric}.js`.
- Deploy artifacts written to `API/build/<target>/` — never overwrite one chain's artifacts with another's.
- Contract naming: `{Entity}Storage.sol` with `store{Entity}()` function and standard envelope fields.

## API Conventions

Port patterns from `repo/lamteknik-blockchain/API/server-lamteknik.js`:

- Single entry point: `API/server-blockchain-api.js`.
- Auto-generate REST routes from deployed contract artifacts at startup.
- Env-driven configuration:

| Variable | Purpose |
|----------|---------|
| `BLOCKCHAIN_TARGET` | Active chain: `besu`, `geth`, `fabric`, `sepolia` |
| `BLOCKCHAIN_RPC_URL` | JSON-RPC endpoint for active EVM chain |
| `CHAIN_ID` | Chain ID for active EVM chain |
| `DEPLOYER_PRIVATE_KEY` | Default transaction signer |
| `BLOCKCHAIN_API_PORT` | API listen port (default `4100`) |

- `GET /health` must report: active target, RPC connectivity, block number, contracts loaded count.
- Validate request input before contract calls.
- Return consistent JSON response shapes across entity routes.
- CORS configurable via `CORS_ORIGIN` env.

### Route layout (EVM)

Entity routes follow the pattern established in the reference:

| Method | Path | Contract call |
|--------|------|--------------|
| `GET` | `/health` | Diagnostic |
| `GET` | `/<app>/<entity>` | `retrieve()` |
| `GET` | `/<app>/<entity>/:recordId` | `get{Entity}(recordId)` |
| `POST` | `/<app>/<entity>` | `store{Entity}(...)` |

Slug derived from contract name: `AkreditasiStorage` → `akreditasi`.

## Backend Docker

Each chain under `backend/<chain>/` follows the Besu pattern:

```
backend/<chain>/
├── docker/
│   └── docker-compose.yml      # Nodes + bundled explorer
├── command/
│   ├── run-<chain>.md          # Startup guide
│   └── reset-<chain>.sh        # Optional chain data reset
├── genesis.json                # EVM only (if applicable)
└── note.txt                    # Optional algorithm notes
```

Rules:

- Besu compose and ports are **immutable** — do not edit to free ports for other chains.
- Geth binds primary RPC to **8555**, Chainlens UI to **8082**.
- Fabric wraps `fabric-samples/test-network`; Explorer on **8090**.
- Sepolia has no Docker node — only `command/run-sepolia.md` and `.env.example`.
- Each Chainlens stack gets its own MongoDB volume — never shared.

## Fabric Chaincode

- Location: `backend/hyperledger-fabric/chaincode/` (preferred) or `API/fabric/` if tightly coupled to deploy scripts.
- Mirror the universal data envelope: `recordId`, timestamps, `modifiedBy`, `allData`.
- v1 success: chaincode deploys and one invoke returns data — REST adapter comes after network is up.
- Do not block Fabric setup on REST API parity with EVM.

## File Organization

```
blockchain-compare/
├── app/                          # Sample app (LamTeknik, minimal subset first)
├── API/
│   ├── server-blockchain-api.js  # Express entry point
│   ├── hardhat.config.js
│   ├── contracts/                # *Storage.sol
│   ├── scripts/
│   │   ├── deploy-besu.js
│   │   ├── deploy-geth.js
│   │   ├── deploy-sepolia.js
│   │   └── deploy-fabric.js
│   ├── build/<target>/           # Deploy artifacts per chain
│   ├── command/                  # API how-to guides
│   ├── .env.example
│   └── package.json
├── backend/
│   ├── hyperledger-besu/         # Done
│   ├── go-ethereum/
│   ├── hyperledger-fabric/
│   └── sepolia-testnet/
├── context/                      # Project specs (this folder)
└── repo/                         # Gitignored reference — not canonical
    └── lamteknik-blockchain/
```

## Command Folder Pattern

Each component documents ops in `command/`:

| Pattern | Example |
|---------|---------|
| `run-<component>.md` | `backend/hyperledger-besu/command/run-besu-ibft.md` |
| `reset-<component>.sh` | `backend/hyperledger-besu/command/reset-besu-ibft.sh` |
| `how-to-<topic>.md` | `API/command/how-to-blockchain-api.md` |

Command docs must include: prerequisites, startup command, port table, explorer URL, env vars, and stop/reset instructions.

## Performance Tests (Deferred)

When implemented, follow these rules:

- Log timestamps: `t_submit`, `t_mined`, `t_confirm` per write.
- Use consistent batch sizes and identical payload across all backends.
- Never compare runs with different payload sizes or entity counts.
- Store results locally (JSON or CSV) with backend name, chain ID, batch size, and timestamp.
- Label results by comparison category (private EVM, Fabric, public EVM) — see `project-overview.md`.

## Secrets

- Besu genesis dev keys are for local development only — document in `.env.example`, never use on mainnet.
- Default Besu deployer address: `0xfe3b557e8fb62b89f4916b721be55ceb828dbd73`.
- Fabric MSP cert paths documented in command docs — certs generated at runtime, not committed.
- Sepolia RPC keys and wallet keys stay in `.env` — never committed.

## What Not to Do

- Do not modify Besu genesis, node keys, compose ports, or embedded Chainlens.
- Do not edit files under `repo/` — port patterns into root folders instead.
- Do not share Chainlens MongoDB volumes between Besu and Geth.
- Do not run multiple blockchain backends simultaneously.
- Do not commit `.env` files with real API keys or private keys.
