#!/usr/bin/env bash
set -euo pipefail

PORT="${PORT:-3000}"

echo "Installing dependencies..."
npm install --no-audit --no-fund

echo "Starting server in background on port ${PORT}..."
# Start server in background
node server.js --host 0.0.0.0 > server.out 2>&1 &
PID=$!

cleanup() {
  echo "Stopping server (PID: $PID)..."
  kill $PID >/dev/null 2>&1 || true
}
trap cleanup EXIT

echo "Waiting for server to be ready..."
for i in {1..30}; do
  if curl -s "http://localhost:${PORT}/health" >/dev/null; then
    break
  fi
  sleep 1
done

echo "Checking /health endpoint..."
RES="$(curl -sS -m 5 "http://localhost:${PORT}/health")"
HTTP_CODE="$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:${PORT}/health")"

echo "HTTP ${HTTP_CODE} Body: ${RES}"

if [ "${HTTP_CODE}" != "200" ]; then
  echo "Health check failed with HTTP ${HTTP_CODE}"
  exit 1
fi

# Simple JSON validation for status field
echo "${RES}" | grep -q '"status"' || { echo "Missing status field in /health"; exit 1; }

echo "OK: /health responded 200 with JSON"
exit 0
