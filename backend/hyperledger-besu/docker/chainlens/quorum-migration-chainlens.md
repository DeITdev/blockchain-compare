# Migration: Quorum Explorer → Chainlens

## Why we migrated

This project previously used **Quorum Explorer** to monitor the private Hyperledger Besu IBFT network (blocks, transactions, nodes, and smart contracts).

Quorum Explorer was removed because its **Docker image is no longer available** (pulled/removed from registries and no longer maintained). That made the old explorer stack unreliable or impossible to deploy on new machines, so it was replaced with a maintained alternative.

## Why Chainlens

**Chainlens** (free developer edition, formerly Epirus) was chosen as the replacement because it:

- Supports **Hyperledger Besu** and private Ethereum-compatible networks
- Runs **entirely locally** via Docker Compose (no required cloud service)
- Is **actively maintained** by Web3 Labs
- Provides a similar role to Quorum Explorer: block/transaction explorer, contract views, and network monitoring

## What changed

| Before (Quorum Explorer) | After (Chainlens) |
|--------------------------|-------------------|
| Single explorer container | Multi-service stack: API, web UI, ingestion, MongoDB, Redis, nginx |
| Unmaintained / image unavailable | `web3labs/epirus-free-*` images from [chainlens-free](https://github.com/web3labs/chainlens-free) |
| — | Explorer UI exposed on **http://localhost:8081** |

Chainlens services are defined in `docker/docker-compose.yml` under the `chainlens-*` services. Configuration files live in `docker/chainlens/` (`nginx.conf`, `5xx.html`).

Ingestion reads chain data from **node-1** RPC:

```text
NODE_ENDPOINT=http://172.16.239.11:8545
```

That is sufficient for this IBFT network because all validators share the same chain state.

## Licensing note

The **Chainlens Free / Developer edition** is free for **evaluation and internal, non-commercial use**. For commercial or production deployments, contact Web3 Labs or use their hosted/enterprise offering. See the [chainlens-free LICENSE](https://github.com/web3labs/chainlens-free/blob/master/LICENSE).

## References

- [chainlens-free (GitHub)](https://github.com/web3labs/chainlens-free)
- [Chainlens documentation — editions](https://www.chainlens.com/documentation-articles/chainlens-blockchain-explorer-versions)
