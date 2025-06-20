#!/bin/bash

NGINX_CONF_PATH="./nginx/conf.d/default.conf"

echo "🔧 Rewriting NGINX config for admin.rocketcitycarbrokers.com..."

cat > "$NGINX_CONF_PATH" <<EOF
server {
    listen 80;
    server_name admin.rocketcitycarbrokers.com;
    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl;
    server_name admin.rocketcitycarbrokers.com;

    ssl_certificate /etc/letsencrypt/live/rocketcitycarbrokers.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/rocketcitycarbrokers.com/privkey.pem;

    location / {
        proxy_pass http://directus:8055/;
        proxy_http_version 1.1;

        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

echo "✅ NGINX config written to $NGINX_CONF_PATH"

echo "🔁 Restarting nginx-jeffops container..."
docker restart nginx-jeffops

echo "⏳ Waiting for container to come back up..."
sleep 5

echo "🧪 Verifying asset MIME type..."
curl -sI https://admin.rocketcitycarbrokers.com/assets/index.js | grep -i Content-Type

echo "✅ If you see Content-Type: application/javascript, you're good!"
echo "🌐 Visit: https://admin.rocketcitycarbrokers.com/"
