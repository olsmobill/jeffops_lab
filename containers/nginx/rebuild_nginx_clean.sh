#!/bin/bash

echo "🧼 Cleaning up previous NGINX container and image..."

cd ~/jeffops_lab/containers/nginx || {
  echo "❌ Failed to navigate to nginx directory."
  exit 1
}

# Stop and remove container if exists
docker stop nginx-jeffops 2>/dev/null
docker rm nginx-jeffops 2>/dev/null

# Remove old image if it exists
docker rmi nginx_web 2>/dev/null

# Build the custom image
echo "⚙️ Rebuilding Docker image..."
docker build -t nginx_web .

# Start container
echo "🚀 Starting container on port 80..."
docker run -d --name nginx-jeffops -p 80:80 nginx_web

# Sanity check
echo -e "\n📦 Active Containers:"
docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"

echo -e "\n🌐 curl localhost:"
curl -s http://localhost

echo -e "\n✅ Rebuild complete. Visit: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)"
