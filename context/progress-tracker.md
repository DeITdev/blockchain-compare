# Progress Tracker

Update this file after every meaningful implementation change.

## Current Phase

**Phase 0 — Context definition and scaffold**

Besu backend is copied and runnable. API, app, Geth, Fabric, and Sepolia are placeholders. Context files defined.

## Current Goal

- Context files finalized (this task).
- Next: get Geth and Fabric backends running (Docker + command docs).

---

## Completed

### Backend infrastructure

- **Hyperledger Besu IBFT** — 4-node network under `backend/hyperledger-besu/` with genesis, node keys, Docker Compose (4 validators + Chainlens on `:8081`), run guide, and reset script.

### Project scaffold

- Folder structure: `app/`, `API/`, `backend/{hyperledger-besu,go-ethereum,hyperledger-fabric,sepolia-testnet}/`.
- Empty API stubs: `server-blockchain-api.js`, `scripts/deploy-besu.js`, `.env.example`.
- `AGENTS.md` and `CLAUDE.md` pointing agents to `context/` files.

### Context

- **`context/project-overview.md`** — project purpose, goals, scope, phase plan.
- **`context/architecture.md`** — stack, boundaries, port map, monitoring, invariants.
- **`context/code-standards.md`** — JS/Hardhat/Solidity conventions, folder layout.
- **`context/ai-workflow-rules.md`** — AI-agent workflow, scoping, verification gates.
- **`context/progress-tracker.md`** — this file.

---

## In Progress

- None.

---

## Next Up

Ordered by user priority — **setup first**, benchmarks and Sepolia deferred:

1. **`backend/go-ethereum/`** — Docker network (target Clique multi-node; `--dev` as smoke fallback), Chainlens on `:8082`, RPC on `:8555`, `command/run-geth.md`.
2. **`backend/hyperledger-fabric/`** — test-network wrapper, chaincode skeleton, Hyperledger Explorer on `:8090`, `command/run-fabric.md`.
3. **Port API from reference** — `server-blockchain-api.js` + Hardhat + contracts + `deploy-besu.js`; extend for Geth.
4. **Port LamTeknik sample into `app/`** — minimal subset (one entity first).
5. *(deferred)* **`backend/sepolia-testnet/`** — RPC-only `.env.example` + `command/run-sepolia.md`.
6. *(deferred)* **Performance benchmark harness** — shared payload, per-chain timing report.
7. *(follow-up)* **Root `README.md`** — single entry point with startup order per backend.

---

## Open Questions

- Geth: `--dev` single node vs multi-node Clique/PoA for fair comparison with Besu 4-node IBFT?
- Fabric chaincode location: `backend/hyperledger-fabric/chaincode/` vs `API/fabric/`?
- Fabric v1 integration: chaincode deploy + CLI invoke only, or Fabric SDK in API from day one?
- *(deferred)* Benchmark output format: JSON vs CSV vs console table?
- *(deferred)* Sepolia role: same benchmark table or separate "public network reference" section?
- *(deferred)* Write path for benchmarks: direct API vs full CDC pipeline?

---

## Architecture Decisions

| Decision | Detail |
|----------|--------|
| Sample app | LamTeknik as first test case; universal `{x}Storage` pattern for future apps |
| Comparison metric | Transaction speed/latency (deferred until backends stable) |
| EVM tooling | Hardhat multi-network config; shared Solidity contracts |
| Sepolia | RPC-only, no local node (deferred) |
| Reference repo | `repo/lamteknik-blockchain/` gitignored; root folders are canonical |
| Alternating backends | Run one chain at a time, never simultaneously |
| Besu ports immutable | RPC 8545–8548, Chainlens 8081 — do not change |
| Geth ports | RPC 8555, Chainlens 8082, optional nodes 8556–8558 |
| Fabric ports | Peers 7051/9051, orderer 7050, Explorer 8090 |
| Monitoring | Each backend owns its explorer stack — not shared |
| Besu monitoring | Chainlens bundled in existing compose (8081) |
| Geth monitoring | Own Chainlens copy with separate MongoDB volume (8082) |
| Fabric monitoring | Hyperledger Explorer (8090) — Chainlens is EVM-only |
| Windows dev | Docker Compose preferred; WSL/Git Bash for `.sh` scripts |

---

## Session Notes

- Reference working stack: `repo/lamteknik-blockchain/run-all.md`.
- Besu RPC default: `http://localhost:8545`, chain ID `1337`.
- Besu deployer (dev): address `0xfe3b557e8fb62b89f4916b721be55ceb828dbd73`, key in genesis alloc — see reference `API/.env.example`.
- Chainlens UI (Besu): `http://localhost:8081`.
- Smart contract algorithm spec: `backend/hyperledger-besu/note.txt`.
- New clones need `repo/lamteknik-blockchain/` obtained manually — it is gitignored.
