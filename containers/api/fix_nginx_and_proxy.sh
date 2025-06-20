#!/bin/bash

echo "🧹 Cleaning up conflicting containers on port 80..."
sudo docker stop containers-web-1 nginx-jeffops 2>/dev/null
sudo docker rm containers-web-1 nginx-jeffops 2>/dev/null

echo "🔧 Rebuilding updated NGINX container..."
cd ~/jeffops_lab/containers/nginx || {
  echo "❌ nginx directory not found"
  exit 1
}
sudo docker-compose up --build -d

echo "✅ NGINX rebuilt. Restarting API container if needed..."
cd ~/jeffops_lab/containers/api || {
  echo "❌ api directory not found"
  exit 1
}
sudo docker-compose up -d

echo "🔍 Verifying connectivity to /api route..."
curl -i http://localhost/api || echo "❌ /api failed"

echo "📦 All done. Test http://<your-EC2-IP>/api in your browser."
