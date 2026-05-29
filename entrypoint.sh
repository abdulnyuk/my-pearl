#!/usr/bin/env bash
set -Eeuo pipefail

: "${WALLET:?WALLET env wajib di-set (format prl1...)}"
case "$WALLET" in
  prl1*) ;;
  *) echo "[err] WALLET harus mulai prl1" >&2; exit 2 ;;
esac

POOL="${POOL_URL:-eu1.alphapool.tech:5566}"
PASS="${POOL_PASSWORD:***"
PREFIX="${WORKER_PREFIX:-salad}"
WORKER_ID="${SALAD_MACHINE_ID:-${HOSTNAME:-unknown}}"
WORKER="${PREFIX}-${WORKER_ID:0:12}"
MASK="${WALLET:0:8}...${WALLET: -6}"

echo "[salad-miner] alpha-miner v1.6.0"
echo "  pool   = $POOL"
echo "  worker = $WORKER"
echo "  wallet = $MASK"

exec /opt/miner/alpha-miner \
  --pool "$POOL" \
  --address "$WALLET" \
  --worker "$WORKER" \
  --password ***"$PASS" \
  --cuda-schedule-spin \
  --devices 0
