#!/usr/bin/env bash
set -euo pipefail

# MongoDB-only startup script for kaviya_database
# - Starts MongoDB
# - Skips any Node viewer auto-start
# - Prints manual instructions for optional viewer
# - Exits 0 after confirming MongoDB is up

DB_NAME="${DB_NAME:-myapp}"
DB_USER="${DB_USER:-appuser}"
DB_PASSWORD="${DB_PASSWORD:-dbuser123}"
DB_PORT="${DB_PORT:-5000}"

echo "[startup] Starting MongoDB only..."

# Ensure required directories exist
sudo mkdir -p /var/lib/mongodb /var/run/mongodb
sudo chown -R "$(whoami)":"$(whoami)" /var/lib/mongodb /var/run/mongodb || true

# Clean up any existing socket files
rm -f /tmp/mongodb-*.sock 2>/dev/null || true

# Start MongoDB in background (fork) so we can verify and then exit
if pgrep -x mongod >/dev/null 2>&1; then
  echo "[startup] mongod already running; continuing with readiness check..."
else
  echo "[startup] Launching mongod..."
  nohup mongod --dbpath /var/lib/mongodb --port "${DB_PORT}" --bind_ip 0.0.0.0,127.0.0.1 --unixSocketPrefix /var/run/mongodb > /var/lib/mongodb/mongod.log 2>&1 &
fi

# Wait for MongoDB to start
echo "[startup] Waiting for MongoDB to become ready on port ${DB_PORT}..."
RETRIES=30
until mongosh --quiet --port "${DB_PORT}" --eval "db.adminCommand('ping')" >/dev/null 2>&1; do
  RETRIES=$((RETRIES-1))
  if [ $RETRIES -le 0 ]; then
    echo "[startup] ERROR: MongoDB failed to become ready in time."
    echo "[startup] Check /var/lib/mongodb/mongod.log for details."
    exit 1
  fi
  sleep 1
done
echo "[startup] MongoDB is up."

# Seed admin/app users if needed (idempotent)
echo "[startup] Ensuring admin/app users exist..."
mongosh --quiet --port "${DB_PORT}" <<EOF
// Create admin user in admin DB if missing
use admin
if (!db.getUser("${DB_USER}")) {
  db.createUser({
    user: "${DB_USER}",
    pwd: "${DB_PASSWORD}",
    roles: [
      { role: "userAdminAnyDatabase", db: "admin" },
      { role: "readWriteAnyDatabase", db: "admin" }
    ]
  })
}

// Create app user in target DB if missing
use ${DB_NAME}
if (!db.getUser("appuser")) {
  db.createUser({
    user: "appuser",
    pwd: "${DB_PASSWORD}",
    roles: [{ role: "readWrite", db: "${DB_NAME}" }]
  })
}
EOF

# Persist connection helper
echo "mongosh mongodb://${DB_USER}:${DB_PASSWORD}@localhost:${DB_PORT}/${DB_NAME}?authSource=admin" > db_connection.txt

# Prepare optional viewer env file (no auto-run)
cat > db_visualizer/mongodb.env << EOF
export MONGODB_URL="mongodb://${DB_USER}:${DB_PASSWORD}@localhost:${DB_PORT}/?authSource=admin"
export MONGODB_DB="${DB_NAME}"
EOF

echo "[startup] MongoDB connection info:"
echo "  DB Name: ${DB_NAME}"
echo "  Admin user: ${DB_USER}"
echo "  App user: appuser"
echo "  Port: ${DB_PORT}"
echo "  Conn cmd (saved to db_connection.txt):"
echo "    $(cat db_connection.txt)"

cat <<'INSTRUCTIONS'

[startup] The Node-based DB viewer will NOT be auto-started.
[startup] To run it manually (optional), execute inside the container:

  cd /kaviya_database/db_visualizer
  # Load env (optional)
  [ -f mongodb.env ] && . mongodb.env
  # Install deps (only if needed)
  npm ci || npm install
  # Start the viewer
  npm start

[Note] The viewer is optional and intended for local debugging only.
INSTRUCTIONS

echo "[startup] Startup completed. MongoDB continues running in the background."
exit 0
