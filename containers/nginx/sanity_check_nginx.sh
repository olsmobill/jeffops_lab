#!/bin/bash

echo "🔍 Checking required files..."
if [[ ! -f Dockerfile ]]; then
  echo "❌ Dockerfile not found"
  exit 1
fi

if [[ ! -f index.html ]]; then
  echo "❌ index.html not found"
  exit 1
fi

echo "✅ Files present. Forcing rebuild..."
sudo docker-compose down --remove-orphans
sudo docker-compose build --no-cache
sudo docker-compose up -d

echo "🕓 Waiting for container to start..."
sleep 5

CONTAINER_NAME="nginx-jeffops"
echo "📦 Inspecting $CONTAINER_NAME contents..."
sudo docker exec -it $CONTAINER_NAME cat /usr/share/nginx/html/index.html
