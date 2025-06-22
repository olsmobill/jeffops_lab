#!/bin/bash
set -e

DOCKERFILE="./directus/Dockerfile"
BACKUP="${DOCKERFILE}.bak.$(date +%Y%m%d_%H%M%S)"

echo "📦 Backing up Dockerfile to $BACKUP"
cp "$DOCKERFILE" "$BACKUP"

if grep -q "apk add --no-cache curl" "$DOCKERFILE"; then
  echo "✅ curl already present in Directus Dockerfile"
else
  echo "🛠️ Adding curl installation to Directus Dockerfile..."
  sed -i '/^FROM/s/$/\nRUN apk add --no-cache curl/' "$DOCKERFILE"
  echo "✅ curl added."
fi

echo "🔄 Rebuilding containers..."
docker compose down
docker compose up -d --build
