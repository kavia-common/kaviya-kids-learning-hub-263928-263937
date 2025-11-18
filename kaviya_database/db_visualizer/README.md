# Simple DB Viewer

Small Express server to view tables/collections across Postgres, MySQL, SQLite, and MongoDB.

How to run:
- Optionally configure Mongo via .env: see .env.example
- Or source env files produced by startup.sh: `source mongodb.env`
- Start server:
  - Production: `npm run start` (includes a prestart step to install deps)
  - Dev: `npm run dev`

Health:
- GET /health -> { status: "ok" }
- GET /api/databases -> tests configured DB connections

Notes:
- Supports MONGODB_URL or MONGODB_URI. For this project MONGODB_URI is preferred.
- Listens on PORT env or 3000 by default.
