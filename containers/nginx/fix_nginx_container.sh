#!/bin/bash

set -e

echo "🔧 Navigating to NGINX container directory..."
cd ~/jeffops_lab/containers/nginx

echo "📄 Creating Dockerfile..."
cat <<EOF > Dockerfile
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/index.html
EOF

echo "📝 Creating index.html..."
cat <<EOF > index.html
<!DOCTYPE html>
<html>
  <head>
    <title>JeffOps Container Success</title>
  </head>
  <body>
    <h1>🚀 JeffOps: NGINX is Live from a Custom Container!</h1>
  </body>
</html>
EOF

echo "🧱 Creating docker-compose.yml..."
cat <<EOF > docker-compose.yml
version: '3'
services:
  web:
    build:
      context: .
    ports:
      - "80:80"
    container_name: nginx-jeffops
EOF

echo "🧹 Stopping and removing any previous containers..."
sudo docker-compose down --remove-orphans

echo "⚙️ Building and starting the custom NGINX container..."
sudo docker-compose up --build -d

echo "✅ Done! Visit your public IP in the browser (http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4))"
