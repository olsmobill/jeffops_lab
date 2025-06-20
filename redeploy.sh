#!/bin/bash
echo "🔁 Pulling latest changes..."
cd /home/ubuntu/jeffops_lab/containers || exit 1
git pull origin main

echo "📦 Rebuilding containers..."
docker compose down
docker compose build
docker compose up -d
