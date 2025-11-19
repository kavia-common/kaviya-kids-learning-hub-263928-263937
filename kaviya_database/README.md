# Kaviya Database Container

This container provides MongoDB only. It must NOT start any Node/Express server by default.

Contents:
- startup.sh: Starts MongoDB, creates users, and writes connection info.
- db_visualizer/: Optional helper Node.js database viewer (Express-based). This is for manual use and should never be invoked automatically by the database container.

Usage:

1) Start MongoDB
   bash startup.sh

2) (Optional) Use the simple DB viewer manually
   cd db_visualizer
   # Load the environment variables created by startup.sh
   source mongodb.env
   npm ci || npm install
   npm run start
   # Then visit http://localhost:3000/health

Notes:
- The database container must not run "node server.js" during its normal startup.
- If you see errors like "Cannot find module ./lib/express", it indicates a corrupted or incorrect Express import path somewhere. The correct import is:
    const express = require('express');
- The db_visualizer is isolated and only starts when you invoke npm scripts manually inside db_visualizer.
