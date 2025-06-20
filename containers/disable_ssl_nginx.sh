#!/bin/bash
set -e

echo "🔧 Disabling SSL in nginx.conf..."

cat << 'NGINX' > ./nginx/default.conf
server {
    listen 80;
    server_name rocketcitycarbrokers.com;

    location / {
        root /usr/share/nginx/html;
        index index.html;
    }

    location /admin/ {
        proxy_pass http://directus:8055/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }

    location /api/ {
        proxy_pass http://containers-api-1:3000/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
NGINX

echo "🔁 Rebuilding and restarting containers..."
docker-compose down
docker-compose up -d --build

echo "✅ SSL disabled. NGINX running on port 80."
