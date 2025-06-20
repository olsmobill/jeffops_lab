#!/bin/bash

COMPOSE_FILE="docker-compose.yml"
BACKUP_FILE="${COMPOSE_FILE}.bak"
VOLUME_LINE='      - ./nginx/default.conf:/etc/nginx/conf.d/default.conf:ro'

echo "📦 Backing up $COMPOSE_FILE to $BACKUP_FILE..."
cp "$COMPOSE_FILE" "$BACKUP_FILE" || { echo "❌ Failed to create backup."; exit 1; }

echo "🔍 Checking if volume line already exists..."
if grep -Fq "$VOLUME_LINE" "$COMPOSE_FILE"; then
  echo "✅ Volume line already present. No changes made."
  exit 0
fi

echo "🔧 Patching docker-compose.yml..."

awk -v v="$VOLUME_LINE" '
/^  web:$/ { web=1 }
web && /^    volumes:$/ { print; print v; web=0; next }
{ print }
' "$BACKUP_FILE" > "$COMPOSE_FILE"

echo "✅ Volume line added under web → volumes."
