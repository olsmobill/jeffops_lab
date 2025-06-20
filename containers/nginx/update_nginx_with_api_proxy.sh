#!/bin/bash

echo "🔧 Updating NGINX container to reverse proxy /api to Node.js app..."

cd ~/jeffops_lab/containers/nginx || {
  echo "❌ Directory not found: ~/jeffops_lab/containers/nginx"
  exit 1
}

# Step 1: Write custom NGINX config with reverse proxy
cat > default.conf <<'EOF'
server {
    listen 80;

    location / {
        root /usr/share/nginx/html;
        index index.html;
    }

    location /api/ {
        proxy_pass http://containers-api-1:3000/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
EOF
echo "✅ Created default.conf with reverse proxy to /api"

# Step 2: Update Dockerfile to copy default.conf into container
cat > Dockerfile <<'EOF'
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/index.html
COPY default.conf /etc/nginx/conf.d/default.conf
EOF
echo "✅ Updated Dockerfile to include default.conf"

# Step 3: Rebuild and restart container
echo "♻️ Rebuilding and restarting NGINX container..."
sudo docker-compose down
sudo docker-compose up --build -d

# Step 4: Confirm container is running
echo "📦 Active containers:"
sudo docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"

echo "🌐 Testing /api routing..."
curl -s http://localhost/api || echo "❌ curl failed — double-check API container is running"

echo "✅ Complete! Test http://<your-EC2-public-IP>/api in your browser."
