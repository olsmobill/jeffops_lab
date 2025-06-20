#!/bin/bash

set -e

NGINX_CONF_PATH="./nginx/conf.d/default.conf"

echo "🛠️ Updating NGINX config to serve frontend at '/'..."

# Backup original config
cp "$NGINX_CONF_PATH" "$NGINX_CONF_PATH.bak"

# Replace the location block for / with frontend proxy
cat > "$NGINX_CONF_PATH" <<EOF
server {
    listen 80;
    listen 443 ssl;
    server_name rocketcitycarbrokers.com;

    ssl_certificate /etc/letsencrypt/live/rocketcitycarbrokers.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/rocketcitycarbrokers.com/privkey.pem;

    location / {
        proxy_pass http://containers-frontend:3000/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    location /admin/ {
        proxy_pass http://directus:8055/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

echo "🔁 Rebuilding NGINX container..."
docker compose up -d --build web

echo "✅ Frontend is now served at https://rocketcitycarbrokers.com/"
