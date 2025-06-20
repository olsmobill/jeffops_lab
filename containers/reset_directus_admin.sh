#!/bin/bash

set -e

COMPOSE_FILE="/home/ubuntu/jeffops_lab/containers/docker-compose.yml"
BACKUP_FILE="/home/ubuntu/jeffops_lab/containers/docker-compose.yml.bak_$(date +%Y%m%d_%H%M%S)"

echo "📦 Backing up docker-compose.yml to $BACKUP_FILE"
cp "$COMPOSE_FILE" "$BACKUP_FILE"

echo "🔧 Updating admin credentials in docker-compose.yml..."

# Use sed to update ADMIN_EMAIL and ADMIN_PASSWORD
sed -i '/ADMIN_EMAIL:/c\      ADMIN_EMAIL: "olsmobill@gmail.com"' "$COMPOSE_FILE"
sed -i '/ADMIN_PASSWORD:/c\      ADMIN_PASSWORD: "B0bbyjones!"' "$COMPOSE_FILE"

echo "🔄 Restarting Docker containers..."
cd /home/ubuntu/jeffops_lab/containers
docker compose down
docker compose up -d

echo "⏳ Waiting for Directus to start..."
sleep 10

echo "🔐 Resetting Directus admin password..."
docker exec -it directus npx directus users set-password olsmobill@gmail.com B0bbyjones!

echo "✅ Admin credentials updated. You can now log in with:"
echo "   Email:    olsmobill@gmail.com"
echo "   Password: B0bbyjones!"
