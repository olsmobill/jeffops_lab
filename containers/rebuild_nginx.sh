#!/bin/bash
cd ~/jeffops_lab/containers || exit 1

echo "🧼 Stopping and removing containers..."
docker compose down

echo "🧱 Rebuilding from scratch..."
docker compose up -d --build

echo "🔍 Verifying NGINX config file in container..."
docker exec -it nginx-jeffops ls -l /etc/nginx/conf.d/
docker exec -it nginx-jeffops cat /etc/nginx/conf.d/default.conf
