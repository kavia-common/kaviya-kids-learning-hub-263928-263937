# Kaviya Database

This container starts MongoDB only.

Startup behavior:
- `startup.sh` launches MongoDB and verifies readiness.
- It does NOT auto-start the Node-based DB viewer to avoid express/module errors and unintended processes.
- After confirming MongoDB is up, the script exits 0 cleanly (status 0) while mongod continues running in background.
- No container health checks or startup hooks invoke "npm start" or "node server.js" anywhere in this container.

Manual DB viewer (optional):
- The DB viewer under `db_visualizer/` is for manual/local debugging only and is not part of the container boot flow.
- If you want to use it manually inside the container:
  ```
  cd /kaviya_database/db_visualizer
  # Install dependencies first (only needed once per image/container):
  npm ci || npm install
  # Optionally load env created by startup.sh:
  [ -f mongodb.env ] && . mongodb.env
  # Then start the viewer:
  npm start
  ```
Notes:
- The viewer is not required for normal operation. Backend services connect directly to MongoDB.
- CI/CD builds and runtime must NOT run the viewer. Ensure no scripts call `db_visualizer/verify-health.sh` as part of container health checks.
- If MongoDB startup issues occur, check `/var/lib/mongodb/mongod.log`.
