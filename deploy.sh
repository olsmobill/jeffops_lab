#!/bin/bash
set -e

echo "🔄 Pulling latest changes from GitHub..."
cd /home/ubuntu/jeffops_lab
git pull origin main

echo "🐳 Restarting Docker containers..."
cd containers
docker compose down
docker compose up -d

echo "✅ Deployment complete."
