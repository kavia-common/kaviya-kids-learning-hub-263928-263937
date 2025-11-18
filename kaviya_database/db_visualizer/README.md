# Simple DB Viewer

Small Express server to view tables/collections across Postgres, MySQL, SQLite, and MongoDB.

How to run:
- Optionally configure Mongo via .env: see .env.example
- Or source env files produced by startup.sh: `source mongodb.env`
- Install dependencies:
  - Install once: `npm install --no-audit --no-fund`
  - Start: `npm run start`
  - Dev (auto-reload): `npm run dev`

What changed (stability fixes):
- Pinned express to 4.18.3 to avoid intermittent `./lib/express` resolution errors.
- Removed prestart install loops; start is now a simple `node server.js`.
- Added postinstall sanity check that logs the installed Express version.
- Added .npmrc to disable audit/fund prompts and avoid workspace/lock-only flags interfering with CI.

Health:
- GET /health -> { status: "ok", service: "simple-db-viewer", express: "4.18.3" }
- GET /api/databases -> tests configured DB connections

Notes:
- Uses `require('express')` only; no relative imports like `./lib/express`.
- Supports MONGODB_URL or MONGODB_URI. For this project MONGODB_URI is preferred.
- Listens on PORT env or 3000 by default. If 3000 is already used, set `PORT=3002` (or another free port) before starting:
  - Example: `PORT=3002 npm run start` then visit `http://localhost:3002/health`

Troubleshooting:
- If you ever see `Cannot find module './lib/express'`:
  1) Move aside node_modules and lock (avoid rm -rf in CI):  
     `mv node_modules node_modules.backup.$(date +%s) 2>/dev/null || true; mv package-lock.json package-lock.backup.$(date +%s) 2>/dev/null || true`
  2) Ensure no local files/folders named `express` or `lib/express` exist in this project.
  3) Reinstall: `npm install --no-audit --no-fund`
  4) Verify: `node -e "console.log(require('express/package.json').version)"` should print 4.18.3
