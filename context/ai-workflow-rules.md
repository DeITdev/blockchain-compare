# AI Workflow Rules

## Approach

Build this project incrementally using a **spec-driven, AI-agent-friendly workflow**. The five files in `context/` define what to build, how to build it, and the current state of progress. Always implement against these specs — do not infer or invent behavior from scratch.

Before any implementation or architectural decision, read in order:

1. [`project-overview.md`](project-overview.md) — product definition and scope
2. [`architecture.md`](architecture.md) — system structure, ports, invariants
3. [`code-standards.md`](code-standards.md) — implementation conventions
4. [`ai-workflow-rules.md`](ai-workflow-rules.md) — this file
5. [`progress-tracker.md`](progress-tracker.md) — current phase and next steps

Use [`repo/lamteknik-blockchain/`](../repo/lamteknik-blockchain/) as a **pattern source**, not as the spec. Port code into root `API/` and `backend/` — do not edit reference in place.

## Scoping Rules

- Work on **one feature unit at a time** — one backend, or one API layer change, or one app slice.
- Prefer small, verifiable increments over large speculative changes.
- Do not combine unrelated system boundaries in a single implementation step.
- Do not implement all four chains in one session.
- Current priority (user confirmed): **Geth and Fabric backend setup first**; Sepolia and benchmarks deferred.

## Phase Gates

| Phase | Gate — do not skip to next phase until |
|-------|----------------------------------------|
| Backend setup | `docker compose up` succeeds; RPC/explorer reachable; `command/run-<chain>.md` written |
| API port | `/health` returns OK; deploy script succeeds; one write returns receipt |
| App port | Sample app writes one record through API to active chain |
| Benchmarks *(deferred)* | All three private backends pass API gate |

## When to Split Work

Split an implementation step if it combines:

- UI/app changes and backend/blockchain changes
- Multiple unrelated API routes or deploy scripts
- Fabric chaincode setup and EVM contract deployment
- Behavior not clearly defined in the context files

If a change cannot be verified end to end quickly, the scope is too broad — split it.

## Contract Adaptation

Smart contracts follow sample app needs — not the reverse.

When the sample app adds or changes entities:

1. Create or update `{x}Storage.sol` with the universal envelope pattern.
2. Update deploy scripts to include the new contract.
3. Restart the API — routes auto-generate from artifacts.
4. Update `progress-tracker.md`.

For Fabric, update equivalent Go chaincode with the same envelope fields.

## Documentation Lookup

Use **Context7 MCP** for authoritative setup docs when implementing new backends:

| Backend | Context7 library ID |
|---------|----------------------|
| Go Ethereum | `/ethereum/go-ethereum` |
| Hyperledger Fabric | `/hyperledger/fabric` |

Query for: Docker setup, private network config, JSON-RPC enablement, test-network deployment, chaincode invoke.

Prefer Context7 over training-data assumptions for CLI flags, version-specific behavior, and breaking changes.

## Handling Missing Requirements

- Do not invent product behavior not defined in the context files.
- If a requirement is ambiguous, resolve it in the relevant context file before implementing.
- If a requirement is missing, add it as an open question in `progress-tracker.md` before continuing.
- If implementation changes architecture, scope, or standards, update the relevant context file first.

## Protected Files

Do not modify unless explicitly instructed:

| Path | Reason |
|------|--------|
| `repo/**` | Reference clone — read-only pattern source |
| `backend/hyperledger-besu/genesis.json` | Immutable network config |
| `backend/hyperledger-besu/Node-*/data/key*` | Validator keys |
| `backend/hyperledger-besu/docker/docker-compose.yml` | Immutable ports and Chainlens |
| `backend/hyperledger-besu/docker/chainlens/**` | Besu Chainlens config |
| `.env` files with secrets | Never commit or overwrite user's keys |

## Keeping Docs in Sync

Update the relevant context file whenever implementation changes:

| Change type | Update |
|-------------|--------|
| Architecture, ports, boundaries | `architecture.md` |
| Coding conventions | `code-standards.md` |
| Scope, goals, features | `project-overview.md` |
| Any meaningful implementation | `progress-tracker.md` |

## Verification Gate

Before marking a backend or API unit as "done":

1. Backend starts via documented `command/run-<chain>.md` steps.
2. Explorer UI loads (Chainlens or Hyperledger Explorer).
3. Deploy script completes without error.
4. API `/health` reports connectivity and contracts loaded.
5. At least one write transaction returns a receipt (EVM) or successful invoke (Fabric).

## Before Moving to the Next Unit

1. The current unit works end to end within its defined scope.
2. No invariant in `architecture.md` was violated.
3. `progress-tracker.md` reflects the completed work.
4. Command doc exists for any new ops steps introduced.

## Windows Considerations

Primary dev environment is Windows 10:

- Prefer Docker Compose over native shell commands.
- `.sh` scripts require Git Bash or WSL — note this in command docs.
- Fabric `network.sh` requires WSL or Git Bash.
- Test commands in PowerShell when providing Windows-specific instructions.

## Reference Repo Onboarding

`repo/lamteknik-blockchain/` is gitignored. New clones will not have it.

Document in command docs that developers must obtain the reference manually:

```
repo/lamteknik-blockchain/   # clone or copy from existing workspace
```

Root folders (`API/`, `backend/`, `app/`) are **canonical** — all implementation targets root, not `repo/`.

## AI-Driven Development Principles

This project is designed for AI agent workflows:

- Context files are the single source of truth — agents read them first.
- Folder structure is predictable — one backend per folder, one command folder per component.
- Contracts adapt to app needs — agents regenerate `{x}Storage` patterns as entities change.
- Repeatable commands in `command/` folders enable agents to start/stop stacks without guessing.
- Small scoped tasks with verification gates prevent runaway multi-chain implementations.
