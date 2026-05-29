#!/usr/bin/env bash
# debug-first entrypoint: log everything ke stdout/stderr biar Salad logs nampung
set -uo pipefail

echo "============================================"
echo "[boot] $(date -u +%FT%TZ) salad-pearl-miner debug entrypoint"
echo "============================================"

echo "[boot] hostname: ${HOSTNAME:-unknown}"
echo "[boot] salad_machine_id: ${SALAD_MACHINE_ID:-unset}"

echo
echo "=== ENV ==="
echo "POOL_URL=${POOL_URL:-unset}"
echo "POOL_PASSWORD=${POOL_PASSWORD:-unset}"
echo "WORKER_PREFIX=${WORKER_PREFIX:-unset}"
if [ -n "${WALLET:-}" ]; then
  echo "WALLET=${WALLET:0:10}...[redacted]"
else
  echo "WALLET=UNSET"
fi

echo
echo "=== GPU ==="
nvidia-smi -L 2>&1 || echo "[err] nvidia-smi -L failed: $?"
echo "--- nvidia-smi summary ---"
nvidia-smi --query-gpu=name,driver_version,compute_cap,memory.total --format=csv 2>&1 | head -5 || true

echo
echo "=== alpha-miner binary ==="
ls -la /opt/miner/alpha-miner 2>&1 | head -3
echo "--- list-devices ---"
/opt/miner/alpha-miner --list-devices 2>&1 | head -10 || echo "[err] list-devices exit: $?"

echo
echo "=== Validate inputs ==="
if [ -z "${WALLET:-}" ]; then echo "[err] WALLET unset" >&2; sleep 60; exit 11; fi
case "$WALLET" in prl1*) ;; *) echo "[err] WALLET invalid prefix" >&2; sleep 60; exit 12;; esac

DEFAULT_POOL='stratum+tcp://us2.alphapool.tech:5566'
DEFAULT_PASS='x;d=131072'
POOL=${POOL_URL:-$DEFAULT_POOL}
PASS=${POOL_PASSWORD:-$DEFAULT_PASS}
PREFIX=${WORKER_PREFIX:-salad}
WORKER_ID=${SALAD_MACHINE_ID:-${HOSTNAME:-unknown}}
WORKER="${PREFIX}-${WORKER_ID:0:12}"

echo "[run] pool   = $POOL"
echo "[run] worker = $WORKER"
echo "[run] pass   = $PASS"
echo "[run] wallet = ${WALLET:0:10}...[redacted]"
echo "============================================"
echo "[run] starting alpha-miner..."
echo "============================================"

exec /opt/miner/alpha-miner \
  --pool "$POOL" \
  --address "$WALLET" \
  --worker "$WORKER" \
  --password "$PASS"
