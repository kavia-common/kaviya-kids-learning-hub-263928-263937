# Simple DB Viewer

Small Express server to view tables/collections across Postgres, MySQL, SQLite, and MongoDB.

How to run:
- Optionally configure Mongo via .env: see .env.example
- Or source env files produced by startup.sh: `source mongodb.env`
- Install deps automatically via prestart when using start:
  - Production: `npm run start` (runs `npm install --no-audit --no-fund` first)
  - Dev: `npm run dev` (install once via `npm install`)

Health:
- GET /health -> { status: "ok" }
- GET /api/databases -> tests configured DB connections

Notes:
- Uses require('express'); no relative imports like './lib/express'
- Supports MONGODB_URL or MONGODB_URI. For this project MONGODB_URI is preferred.
- Listens on PORT env or 3000 by default.
