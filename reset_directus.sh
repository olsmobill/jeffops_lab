#!/bin/bash

set -e

COMPOSE_DIR="/home/ubuntu/jeffops_lab/containers"
COMPOSE_FILE="$COMPOSE_DIR/docker-compose.yml"

echo "📦 Stopping Directus container..."
docker compose -f "$COMPOSE_FILE" stop directus

echo "🧼 Deleting old SQLite DB from 'directus_data' volume..."
docker volume inspect directus_data >/dev/null 2>&1 && \
docker run --rm -v directus_data:/data alpine sh -c "rm -f /data/data.db" || \
echo "ℹ️ Volume 'directus_data' not found or already clean."

echo "🔐 Injecting new admin credentials into docker-compose.yml..."

yq eval '
.services.directus.environment = [
  "ADMIN_EMAIL=olsmobill@gmail.com",
  "ADMIN_PASSWORD=B0bbyjones!",
  "SECRET=changeme-secret",
  "PUBLIC_URL=https://admin.rocketcitycarbrokers.com",
  "DB_CLIENT=sqlite3",
  "DB_FILENAME=/directus/database/data.db"
]
' -i "$COMPOSE_FILE"

echo "🚀 Starting Directus fresh..."
docker compose -f "$COMPOSE_FILE" up -d directus

echo "✅ Admin credentials updated and Directus restarted."
