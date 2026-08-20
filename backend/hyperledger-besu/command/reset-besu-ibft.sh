#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "Resetting Besu blockchain data in: ${ROOT_DIR}"
echo "Stop all Besu nodes before running this script."
echo

for data_dir in "${ROOT_DIR}"/Node-*/data; do
  if [[ ! -d "${data_dir}" ]]; then
    continue
  fi

  node_name="$(basename "$(dirname "${data_dir}")")"
  echo "Resetting ${node_name}..."

  rm -rf "${data_dir}/caches" "${data_dir}/database"
  rm -f \
    "${data_dir}/DATABASE_METADATA.json" \
    "${data_dir}/VERSION_METADATA.json" \
    "${data_dir}/besu.networks" \
    "${data_dir}/besu.ports"

  echo "  Removed caches/, database/, DATABASE_METADATA.json, VERSION_METADATA.json, besu.networks, besu.ports"
done

echo
echo "Reset complete. Node keys (key, key.pub) were kept."
echo "Start the nodes again to resync from genesis."
