#!/usr/bin/env bash
# WARNING: This script is for MANUAL local verification only.
# Do NOT call this from container startup or health checks.
# It installs npm packages and starts the viewer process temporarily.
set -euo pipefail

PORT="${PORT:-3000}"

echo "[verify-health] Installing dependencies (manual use only)..."
npm ci || npm install --no-audit --no-fund

echo "[verify-health] Starting server in background on port ${PORT}..."
node server.js --host 0.0.0.0 > server.out 2>&1 &
PID=$!

cleanup() {
  echo "[verify-health] Stopping server (PID: $PID)..."
  kill $PID >/dev/null 2>&1 || true
}
trap cleanup EXIT

echo "[verify-health] Waiting for server to be ready..."
for i in {1..30}; do
  if curl -s "http://localhost:${PORT}/health" >/dev/null; then
    break
  fi
  sleep 1
done

echo "[verify-health] Checking /health endpoint..."
RES="$(curl -sS -m 5 "http://localhost:${PORT}/health")"
HTTP_CODE="$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:${PORT}/health")"

echo "[verify-health] HTTP ${HTTP_CODE} Body: ${RES}"

if [ "${HTTP_CODE}" != "200" ]; then
  echo "[verify-health] Health check failed with HTTP ${HTTP_CODE}"
  exit 1
fi

# Simple JSON validation for status field
echo "${RES}" | grep -q '"status"' || { echo "[verify-health] Missing status field in /health"; exit 1; }

echo "[verify-health] OK: /health responded 200 with JSON"
exit 0
