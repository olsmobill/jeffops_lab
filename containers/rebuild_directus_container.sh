#!/bin/bash

echo "🧹 Stopping and removing existing Directus container..."
docker stop directus && docker rm directus

echo "🚀 Rebuilding Directus container from latest image..."
docker pull directus/directus:11.8.0

docker run -d \
  --name directus \
  -p 8055:8055 \
  -v containers_directus_data:/data \
  --restart unless-stopped \
  directus/directus:11.8.0

echo "⏳ Waiting 10 seconds for Directus to start..."
sleep 10

echo "📋 Running bootstrap (migrate, initialize if needed)..."
docker exec -it directus npx directus bootstrap

echo "✅ Directus rebuilt and running at: https://admin.rocketcitycarbrokers.com"
