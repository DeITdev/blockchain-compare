# Run Besu nodes on Mac

Run each command from the corresponding node directory (e.g. `Node-1`, `Node-2`).

## Node-1

```bash
besu --data-path=data --genesis-file=../genesis.json --rpc-http-enabled --rpc-http-api=ETH,NET,IBFT --host-allowlist="*" --rpc-http-cors-origins="all" --profile=ENTERPRISE
```

## Node-2

```bash
besu --data-path=data --genesis-file=../genesis.json --bootnodes=enode://8fbfa5c13e0913f9bfbbf8a08ecc90ca7c13bc9d33a86e5e9b6aae814f1b501195977fbedac8f94bd4cf4bf90fceb9966572c03dcde7e170110c6a6be78d2048@127.0.0.1:30303 --p2p-port=30304 --rpc-http-enabled --rpc-http-api=ETH,NET,IBFT --host-allowlist="*" --rpc-http-cors-origins="all" --rpc-http-port=8546 --profile=ENTERPRISE
```

## Node-3

```bash
besu --data-path=data --genesis-file=../genesis.json --bootnodes=enode://8fbfa5c13e0913f9bfbbf8a08ecc90ca7c13bc9d33a86e5e9b6aae814f1b501195977fbedac8f94bd4cf4bf90fceb9966572c03dcde7e170110c6a6be78d2048@127.0.0.1:30303 --p2p-port=30305 --rpc-http-enabled --rpc-http-api=ETH,NET,IBFT --host-allowlist="*" --rpc-http-cors-origins="all" --rpc-http-port=8547 --profile=ENTERPRISE
```

## Node-4

```bash
besu --data-path=data --genesis-file=../genesis.json --bootnodes=enode://8fbfa5c13e0913f9bfbbf8a08ecc90ca7c13bc9d33a86e5e9b6aae814f1b501195977fbedac8f94bd4cf4bf90fceb9966572c03dcde7e170110c6a6be78d2048@127.0.0.1:30303 --p2p-port=30306 --rpc-http-enabled --rpc-http-api=ETH,NET,IBFT --host-allowlist="*" --rpc-http-cors-origins="all" --rpc-http-port=8548 --profile=ENTERPRISE
```

## Node-5

```bash
besu --data-path=data --genesis-file=../genesis.json --bootnodes=enode://8fbfa5c13e0913f9bfbbf8a08ecc90ca7c13bc9d33a86e5e9b6aae814f1b501195977fbedac8f94bd4cf4bf90fceb9966572c03dcde7e170110c6a6be78d2048@127.0.0.1:30303 --p2p-port=30307 --rpc-http-enabled --rpc-http-api=ETH,NET,IBFT --host-allowlist="*" --rpc-http-cors-origins="all" --rpc-http-port=8549 --profile=ENTERPRISE
```
