# Run Go Ethereum (Geth) — dev mode + Chainlens

Docker Compose stack for a single-node Geth **dev chain** with Chainlens block explorer. Use this backend when `BLOCKCHAIN_TARGET=geth`.

## Consensus rationale

Modern Geth (v1.14+) **cannot seal Clique or Ethash blocks**. The official local-dev path is **`--dev` mode** (single node, chain ID 1337). Multi-node private Geth today requires **PoS + a consensus client** (typically via [Kurtosis](https://geth.ethereum.org/docs/fundamentals/kurtosis)) — not included in this repo.

| Backend | Topology | Consensus | Production note |
|---------|----------|-----------|-----------------|
| **Besu** (this project) | 4-node IBFT | PoA (IBFT 2.0) | QBFT is Besu's production recommendation; IBFT 2.0 is dev/existing-network grade |
| **Geth** (this stack) | 1-node `--dev` | Dev/simulated | Local contract testing only — not a production network |

**Comparison scope:** same Solidity contracts and API write path across Besu and Geth. Topology differs (4-node IBFT vs 1-node dev) — document that when interpreting latency benchmarks.

## Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (Windows, macOS, or Linux)
- **Stop Besu** (or any other backend) before starting Geth — only one backend runs at a time
- Free host ports: **8555** (RPC), **8082** (Chainlens UI via nginx)
- For `reset-geth.sh`: Git Bash or WSL on Windows

## Quick start

From the repository root:

```bash
cd backend/go-ethereum/docker
docker compose up -d
```

Wait until `geth-dev` is healthy (~30s on first start while images pull):

```bash
docker compose ps
```

## Port map

| Service | Host port | Purpose |
|---------|-----------|---------|
| Geth JSON-RPC | **8555** | Primary RPC (`http://localhost:8555`) |
| Chainlens UI | **8082** | Block explorer — use **`http://127.0.0.1:8082`** (see Explorer section) |
| Chainlens API / WS | **8090** | WebSocket endpoint (`ws://localhost:8090`) — API also proxied at `/api` via nginx |
| 8556–8558 | — | Reserved by architecture; **unused** in `--dev` mode |

Internal Docker network: `172.16.240.0/24` (Geth node at `172.16.240.11`).

## Explorer

Open **http://127.0.0.1:8082** after the stack is up (use `127.0.0.1`, not `localhost` — see note below). Chainlens uses **nginx on port 8082** as the single entry point — it proxies `/` to the web UI and `/api/` to the API.

**Why `127.0.0.1` and not `localhost`?** Browsers share cookies across all ports for the `localhost` hostname. If you previously used Besu Chainlens on `:8081`, stale cookies can break Geth Chainlens on `:8082` with a `400 Bad Request` JSON error. Using `127.0.0.1` avoids that conflict.

**If you still see `{"error":"Bad Request","message":"Client Error","statusCode":400}`:**

1. Clear site data for `localhost` in Chrome: DevTools → Application → Cookies → delete entries for `localhost`, then hard-refresh (`Ctrl+Shift+R`), or use Incognito.

Wait until `geth-chainlens-web` is **healthy** before opening the UI (~1–2 minutes on first start while Next.js builds):

```powershell
docker compose ps
docker logs geth-chainlens-web -f
```

Look for `Ready on http://localhost:3000` in the logs. Nginx will not start until the web container passes its healthcheck, which avoids transient 502/400 errors during startup.

Chainlens ingestion reads RPC from the Geth container at `http://172.16.240.11:8555`.

Chainlens uses a **separate MongoDB volume** from Besu — never share ingestion databases between backends.

## API / Hardhat environment

```bash
BLOCKCHAIN_TARGET=geth
BLOCKCHAIN_RPC_URL=http://localhost:8555
CHAIN_ID=1337
```

## Developer account

Geth `--dev` mode creates and funds a developer account automatically. On first start, read the address from container logs:

```bash
docker logs geth-dev 2>&1 | findstr /i "account"
```

On Git Bash / macOS / Linux:

```bash
docker logs geth-dev 2>&1 | grep -i account
```

**Note:** Besu uses a fixed genesis deployer (`0xfe3b557e8fb62b89f4916b721be55ceb828dbd73`). Geth `--dev` uses its **own** auto-generated funded account. When deploying contracts in Phase 2, configure Hardhat/`API/.env` with the Geth dev account — not the Besu genesis key.

## Verify connectivity

**Chain ID** (expect `0x539` = 1337):

```bash
curl -s -X POST http://localhost:8555 \
  -H "Content-Type: application/json" \
  -d "{\"jsonrpc\":\"2.0\",\"method\":\"eth_chainId\",\"params\":[],\"id\":1}"
```

**Latest block** (increments every ~2s with `--dev.period=2`):

```bash
curl -s -X POST http://localhost:8555 \
  -H "Content-Type: application/json" \
  -d "{\"jsonrpc\":\"2.0\",\"method\":\"eth_blockNumber\",\"params\":[],\"id\":1}"
```

**Attach console** (optional):

```bash
docker exec -it geth-dev geth attach http://127.0.0.1:8555
```

## Stop the stack

```bash
cd backend/go-ethereum/docker
docker compose down
```

To remove Chainlens MongoDB data as well (full explorer reset):

```bash
docker compose down -v
```

## Reset chain data

Wipes local dev chain state under `backend/go-ethereum/data/` but keeps Docker images/volumes unless you pass `-v`.

1. Stop the stack: `docker compose down`
2. From repo root (Git Bash / WSL):

```bash
./backend/go-ethereum/command/reset-geth.sh
```

3. Start again: `cd backend/go-ethereum/docker && docker compose up -d`

## Troubleshooting

| Issue | What to check |
|-------|----------------|
| Port 8555 or 8082 in use | Stop Besu (`8545`/`8081`) or another Geth instance; run `docker compose down` in the other backend |
| `geth-dev` unhealthy | `docker logs geth-dev` — first pull of `ethereum/client-go:stable` can take time |
| Chainlens `400 Bad Request` | Use **http://127.0.0.1:8082**; clear `localhost` cookies (conflict with Besu :8081); or use Incognito |
| Chainlens 502 during startup | Normal for ~1–2 min; web container is still building — wait for `Ready on http://localhost:3000` in logs |
| Chainlens stale data | Wait for ingestion; check `docker logs geth-chainlens-ingestion` |
| Wrong chain ID in API | Confirm `CHAIN_ID=1337` and RPC URL is `http://localhost:8555` |
| Besu still running | Only one backend at a time — stop Besu compose before starting Geth |

## Future: multi-node Geth

For a multi-node private network aligned with current Geth docs, see [Private network via Kurtosis](https://geth.ethereum.org/docs/fundamentals/kurtosis). That path uses PoS (execution + consensus clients) and is intentionally **out of scope** for this comparison project's Phase 1.

## File layout

```
backend/go-ethereum/
├── command/
│   ├── run-geth.md          # this file
│   └── reset-geth.sh
├── data/                    # dev chain datadir (gitignored)
└── docker/
    ├── docker-compose.yml
    └── chainlens/
        ├── nginx.conf
        └── 5xx.html
```

## Licensing note (Chainlens)

Chainlens Free / Developer edition is free for evaluation and internal, non-commercial use. See [chainlens-free LICENSE](https://github.com/web3labs/chainlens-free/blob/master/LICENSE).
