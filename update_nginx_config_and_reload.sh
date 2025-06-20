#!/bin/bash

echo "🔧 Writing new NGINX config for React frontend + API..."
cat <<EOF > ~/jeffops_lab/containers/nginx/default.conf
server {
    listen 80;
    server_name rocketcitycarbrokers.com www.rocketcitycarbrokers.com;
    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl;
    server_name rocketcitycarbrokers.com www.rocketcitycarbrokers.com;

    ssl_certificate /etc/letsencrypt/live/rocketcitycarbrokers.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/rocketcitycarbrokers.com/privkey.pem;

    location /api/ {
        proxy_pass http://host.docker.internal:3001/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }

    location / {
        proxy_pass http://host.docker.internal:3002/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF

echo "📦 Rebuilding and restarting nginx-jeffops container..."
docker rm -f nginx-jeffops
docker build -t olsmobill/nginx-web:latest ~/jeffops_lab/containers/nginx
docker run -d \
  --name nginx-jeffops \
  --network jeffops-net \
  -p 80:80 \
  -p 443:443 \
  -v /etc/letsencrypt:/etc/letsencrypt:ro \
  olsmobill/nginx-web:latest

echo "✅ NGINX redeployed. Visit: https://rocketcitycarbrokers.com/"
