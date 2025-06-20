#!/bin/bash

set -e

COMPOSE_FILE="docker-compose.yml"
BACKUP_FILE="docker-compose.yml.bak"

echo "📦 Backing up ${COMPOSE_FILE} to ${BACKUP_FILE}..."
cp "$COMPOSE_FILE" "$BACKUP_FILE"

echo "🔧 Updating nginx volume mount for default.conf..."

# Use awk to rewrite the volumes block under the `web:` service
awk '
BEGIN { in_web = 0 }
/^\s*web:/ { in_web = 1; print; next }
in_web && /^\s*[a-zA-Z0-9_]+:/ { in_web = 0 }
in_web && /^\s*volumes:/ {
  print "      - /etc/letsencrypt/live/rocketcitycarbrokers.com:/etc/nginx/certs:ro"
  print "      - ./nginx:/etc/nginx/conf.d:ro"
  skip_volumes = 1
  next
}
in_web && skip_volumes && /^\s*- / { next }
{ print }
' "$BACKUP_FILE" > "$COMPOSE_FILE"

echo "✅ docker-compose.yml updated with correct nginx volumes."
