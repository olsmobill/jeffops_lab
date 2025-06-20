#!/bin/bash

echo "🔧 Ensuring you're in the correct NGINX container directory..."
cd ~/jeffops_lab/containers/nginx || {
  echo "❌ Directory not found"; exit 1;
}

echo "📝 Regenerating index.html..."
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

echo "🐳 Regenerating Dockerfile..."
cat <<EOF > Dockerfile
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/index.html
EOF

echo "📄 Contents of index.html:"
cat index.html

echo "⚙️ Rebuilding container from scratch..."
docker stop nginx-jeffops 2>/dev/null
docker rm nginx-jeffops 2>/dev/null
docker rmi nginx_web 2>/dev/null

docker build -t nginx_web .

echo "🚀 Starting new container..."
docker run -d --name nginx-jeffops -p 80:80 nginx_web

echo "🌐 curl check:"
curl -s http://localhost | grep JeffOps

echo -e "✅ Done. Try: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)"

