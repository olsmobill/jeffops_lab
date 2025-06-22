#!/bin/bash

echo "📦 Creating Directus Dockerfile with curl support..."

# Step 1: Create directus directory
mkdir -p ./directus

# Step 2: Create Dockerfile
cat <<EOF > ./directus/Dockerfile
FROM directus/directus:11.8.0

RUN apk add --no-cache curl
EOF

echo "✅ Dockerfile created at ./directus/Dockerfile"

# Step 3: Backup docker-compose.yml
timestamp=$(date +%Y%m%d_%H%M%S)
cp docker-compose.yml docker-compose.yml.bak.$timestamp
echo "🛡️ Backed up docker-compose.yml to docker-compose.yml.bak.$timestamp"

# Step 4: Patch docker-compose.yml to build Directus from Dockerfile
# Only if it still uses the image line
if grep -q 'directus/directus:11.8.0' docker-compose.yml; then
  sed -i '/directus:/,/^[^ ]/ s|^\(\s*\)image: directus/directus:11.8.0|\1build:\n\1  context: ./directus\n\1  dockerfile: Dockerfile|' docker-compose.yml
  echo "🔧 docker-compose.yml updated to build Directus from local Dockerfile."
else
  echo "⚠️ Skipping compose patch – build config already present or image name missing."
fi

# Step 5: Rebuild
echo "🔄 Rebuilding containers..."
docker compose down
docker compose up -d --build
