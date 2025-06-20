#!/bin/bash

set -e

echo "🔐 [1/3] Setting up Certbot auto-renewal cron job..."

# Create renewal hook to rebuild nginx container after cert renewal
RENEW_HOOK="/etc/letsencrypt/renewal-hooks/deploy/rebuild-nginx.sh"

sudo tee "$RENEW_HOOK" > /dev/null <<'EOF'
#!/bin/bash
echo "🔄 SSL certs renewed. Rebuilding NGINX container..."
docker rm -f nginx-jeffops || true
docker build -t olsmobill/nginx-web:latest /home/ubuntu/jeffops_lab/containers/nginx
docker run -d \
  --name nginx-jeffops \
  --network jeffops-net \
  -p 80:80 -p 443:443 \
  -v /etc/letsencrypt:/etc/letsencrypt:ro \
  olsmobill/nginx-web:latest
EOF

sudo chmod +x "$RENEW_HOOK"

# Add to root's crontab (twice daily attempt)
(crontab -l 2>/dev/null; echo "0 0,12 * * * /usr/bin/certbot renew --quiet") | sudo crontab -

echo "✅ Auto-renewal setup complete."


echo "🌐 [2/3] Updating NGINX config to redirect HTTP to HTTPS..."

REDIRECT_CONF="/home/ubuntu/jeffops_lab/containers/nginx/default.conf"

sudo tee "$REDIRECT_CONF" > /dev/null <<EOF
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

    location / {
        root /usr/share/nginx/html;
        index index.html;
    }

    location /api/ {
        proxy_pass http://containers-api-1:3000/;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        rewrite ^/api/(.*)$ /$1 break;
    }
}
EOF

echo "✅ HTTPS redirect config written."


echo "🖥️ [3/3] Deploying production frontend (optional placeholder)..."

FRONTEND_HTML="/home/ubuntu/jeffops_lab/containers/nginx/index.html"

cat <<EOF > "$FRONTEND_HTML"
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8">
    <title>RocketCity: Prop Firm</title>
  </head>
  <body style="font-family: sans-serif; text-align: center; padding-top: 50px;">
    <h1>🚀 RocketCity is live over HTTPS!</h1>
    <p>Your secure dashboard is ready to go.</p>
  </body>
</html>
EOF

echo "📦 Rebuilding NGINX container..."

docker rm -f nginx-jeffops || true

docker build -t olsmobill/nginx-web:latest /home/ubuntu/jeffops_lab/containers/nginx

docker run -d \
  --name nginx-jeffops \
  --network jeffops-net \
  -p 80:80 -p 443:443 \
  -v /etc/letsencrypt:/etc/letsencrypt:ro \
  olsmobill/nginx-web:latest

echo "🎉 All done. HTTPS, redirects, and frontend deployed."
