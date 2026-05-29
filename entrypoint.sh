#!/usr/bin/env bash
# debug-first entrypoint: log everything ke stdout/stderr biar Salad logs nampung
set -uo pipefail

echo "============================================"
echo "[boot] $(date -u +%FT%TZ) salad-pearl-miner debug entrypoint"
echo "============================================"

echo "[boot] hostname: ${HOSTNAME:-unknown}"
echo "[boot] salad_machine_id: ${SALAD_MACHINE_ID:-unset}"

echo
echo "=== ENV (filtered) ==="
env | grep -E '^(WALLET|POOL|WORKER|CUDA|NVIDIA)' | sed 's|\(WALLET=prl1\)\([^=]\{0,8\}\).*|\1\2... [redacted]|' || true

echo
echo "=== GPU ==="
nvidia-smi -L 2>&1 || echo "[err] nvidia-smi -L failed: $?"
echo "--- nvidia-smi summary ---"
nvidia-smi --query-gpu=name,driver_version,compute_cap,memory.total --format=csv 2>&1 | head -5 || true

echo
echo "=== alpha-miner binary ==="
ls -la /opt/miner/alpha-miner 2>&1 | head -3
file /opt/miner/alpha-miner 2>&1 | head -1
echo "--- list-devices ---"
/opt/miner/alpha-miner --list-devices 2>&1 | head -10 || echo "[err] list-devices exit: $?"
echo "--- help (first lines) ---"
/opt/miner/alpha-miner --help 2>&1 | head -20 || true

echo
echo "=== Validate inputs ==="
if [ -z "${WALLET:-}" ]; then echo "[err] WALLET unset" >&2; sleep 60; exit 11; fi
case "$WALLET" in prl1*) ;; *) echo "[err] WALLET invalid prefix" >&2; sleep 60; exit 12;; esac

POOL="${POOL_URL:-stratum+tcp://us2.alphapool.tech:5566}"
PASS="${POOL_PASSWORD:***"
PREFIX="${WORKER_PREFIX:-salad}"
WORKER_ID="${SALAD_MACHINE_ID:-${HOSTNAME:-unknown}}"
WORKER="${PREFIX}-${WORKER_ID:0:12}"

echo "[run]   pool   = $POOL"
echo "[run]   worker = $WORKER"
echo "[run]   pass   = $PASS"
echo "[run]   wallet = ${WALLET:0:8}...${WALLET: -6}"
echo "============================================"
echo "[run] starting alpha-miner..."
echo "============================================"

exec /opt/miner/alpha-miner \
  --pool "$POOL" \
  --address "$WALLET" \
  --worker "$WORKER" \
  --password ***"$PASS"
