# Progress Tracker

Update this file after every meaningful implementation change.

## Current Phase

**Phase 1 — Backend setup (Geth + Fabric)**

Besu backend is runnable. Geth dev-mode Docker + Chainlens config scaffolded. Fabric and API remain next.

## Current Goal

- Geth config complete — user validates with `docker compose up`.
- Next: Fabric backend (Docker + command docs).

---

## Completed

### Backend infrastructure

- **Hyperledger Besu IBFT** — 4-node network under `backend/hyperledger-besu/` with genesis, node keys, Docker Compose (4 validators + Chainlens on `:8081`), run guide, and reset script.
- **Go Ethereum (Geth) dev mode** — single-node `--dev` stack under `backend/go-ethereum/` with Docker Compose (Geth on `:8555` + Chainlens on `:8082`), `command/run-geth.md`, and `reset-geth.sh`. Clique deprecated in Geth v1.14+; topology asymmetry vs Besu 4-node IBFT documented intentionally.

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

1. **`backend/hyperledger-fabric/`** — test-network wrapper, chaincode skeleton, Hyperledger Explorer on `:8090`, `command/run-fabric.md`.
2. **Port API from reference** — `server-blockchain-api.js` + Hardhat + contracts + `deploy-besu.js`; extend for Geth.
3. **Port LamTeknik sample into `app/`** — minimal subset (one entity first).
4. *(deferred)* **`backend/sepolia-testnet/`** — RPC-only `.env.example` + `command/run-sepolia.md`.
5. *(deferred)* **Performance benchmark harness** — shared payload, per-chain timing report.
6. *(follow-up)* **Root `README.md`** — single entry point with startup order per backend.
7. *(optional future)* **Geth multi-node via Kurtosis PoS** — official modern path; not in Phase 1 scope.

---

## Open Questions

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
| Geth consensus | `--dev` single node (Geth v1.14+); Clique deprecated; Kurtosis PoS multi-node deferred |
| Fabric monitoring | Hyperledger Explorer (8090) — Chainlens is EVM-only |
| Windows dev | Docker Compose preferred; WSL/Git Bash for `.sh` scripts |

---

## Session Notes

- Reference working stack: `repo/lamteknik-blockchain/run-all.md`.
- Besu RPC default: `http://localhost:8545`, chain ID `1337`.
- Besu deployer (dev): address `0xfe3b557e8fb62b89f4916b721be55ceb828dbd73`, key in genesis alloc — see reference `API/.env.example`.
- Chainlens UI (Besu): `http://localhost:8081`.
- Geth RPC default: `http://localhost:8555`, chain ID `1337` (`--dev` mode).
- Chainlens UI (Geth): **http://127.0.0.1:8082** (use `127.0.0.1`, not `localhost`, to avoid cookie clash with Besu :8081).
- Geth runbook: `backend/go-ethereum/command/run-geth.md`.
- Smart contract algorithm spec: `backend/hyperledger-besu/note.txt`.
- New clones need `repo/lamteknik-blockchain/` obtained manually — it is gitignored.
