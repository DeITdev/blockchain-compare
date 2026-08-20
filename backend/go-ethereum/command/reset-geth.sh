#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
DATA_DIR="${ROOT_DIR}/data"

echo "Resetting Geth dev chain data in: ${DATA_DIR}"
echo "Stop the stack first: cd ${ROOT_DIR}/docker && docker compose down"
echo

if [[ ! -d "${DATA_DIR}" ]]; then
  echo "No data directory found — nothing to reset."
  exit 0
fi

echo "Removing chain data under ${DATA_DIR}..."
rm -rf "${DATA_DIR}/geth"

echo
echo "Reset complete. Start the stack again for a fresh dev chain:"
echo "  cd ${ROOT_DIR}/docker && docker compose up -d"
