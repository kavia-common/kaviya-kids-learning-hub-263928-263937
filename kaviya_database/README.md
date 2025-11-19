# Kaviya Database

This container starts MongoDB only.

Startup behavior:
- `startup.sh` launches MongoDB and verifies readiness.
- It does NOT auto-start the Node-based DB viewer to avoid express/module errors and unintended processes.
- After confirming MongoDB is up, the script exits 0 cleanly.

Manual DB viewer (optional):
- For local debugging only, you can start the viewer manually inside the container:
  ```
  cd /kaviya_database/db_visualizer
  npm ci || npm install
  npm start
  ```
Notes:
- The viewer is not required for normal operation. Backend services connect directly to MongoDB.
- If startup issues occur, check `/var/log/mongodb.log`.
