#!/bin/bash
set -e

echo "🔧 Overwriting docker-compose.yml..."
cat > docker-compose.yml <<'EOF'
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
    image: directus/directus:latest
    container_name: directus
    ports:
      - "8055:8055"
    volumes:
      - directus_data:/data
    environment:
      ADMIN_EMAIL: admin@example.com
      ADMIN_PASSWORD: Admin1234
      DB_CLIENT: sqlite
      DB_FILENAME: /data/db.sqlite
    networks:
      - jeffops-net

networks:
  jeffops-net:

volumes:
  directus_data:
EOF

echo "🔧 Overwriting nginx.conf..."
cat > nginx/default.conf <<'EOF'
server {
  listen 80;

  location / {
    root /usr/share/nginx/html;
    index index.html;
  }

  location /api/ {
    proxy_pass http://api:3000/;
  }

  location /admin/ {
    proxy_pass http://directus:8055/;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection 'upgrade';
    proxy_set_header Host $host;
    proxy_cache_bypass $http_upgrade;
  }
}
EOF

echo "🔄 Restarting Docker containers..."
docker-compose down
docker-compose up -d --build

echo "✅ Done. Test Directus at: http://3.210.232.161/admin/"
