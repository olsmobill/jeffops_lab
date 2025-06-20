#!/bin/bash

set -e

echo "📦 Backing up current docker-compose.yml..."
cp ~/jeffops_lab/containers/docker-compose.yml ~/jeffops_lab/containers/docker-compose.yml.bak.$(date +%s)

echo "✏️ Updating Directus service to use SQLite..."

# Replace the environment block in docker-compose.yml
cat > ~/jeffops_lab/containers/docker-compose.yml <<'EOF'
services:
  api:
    container_name: containers-api-1
    build:
      context: ./api
    ports:
      - "3000:3000"
    networks:
      - jeffops-net

  web:
    container_name: nginx-jeffops
    build:
      context: ./nginx
    ports:
      - "80:80"
    depends_on:
      - api
      - directus
    networks:
      - jeffops-net

  directus:
    image: directus/directus:10.11.2
    container_name: directus
    ports:
      - "8055:8055"
    volumes:
      - directus_data:/directus/database
    environment:
      SECRET: "changeme-secret-$(openssl rand -hex 8)"
      ADMIN_EMAIL: "admin@example.com"
      ADMIN_PASSWORD: "d1r3ctu5"
      DB_CLIENT: "sqlite3"
      DB_FILENAME: "/directus/database/data.db"
    networks:
      - jeffops-net

networks:
  jeffops-net:

volumes:
  directus_data:
EOF

echo "♻️ Rebuilding and restarting all containers..."
cd ~/jeffops_lab/containers
docker compose down -v
docker compose up -d --build

echo "📜 Waiting for Directus logs..."
sleep 5
docker logs -f directus
