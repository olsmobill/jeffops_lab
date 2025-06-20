#!/bin/bash

set -e

DEFAULT_CONF_PATH="$HOME/jeffops_lab/containers/nginx/default.conf"

echo "📄 Patching default.conf to use correct Let's Encrypt SSL paths..."

# Backup original config
cp "$DEFAULT_CONF_PATH" "${DEFAULT_CONF_PATH}.bak"

# Use sed to replace incorrect SSL paths
sed -i \
    -e 's|ssl_certificate\s\+/etc/nginx/certs/fullchain.pem;|ssl_certificate /etc/nginx/certs/live/rocketcitycarbrokers.com/fullchain.pem;|' \
    -e 's|ssl_certificate_key\s\+/etc/nginx/certs/privkey.pem;|ssl_certificate_key /etc/nginx/certs/live/rocketcitycarbrokers.com/privkey.pem;|' \
    "$DEFAULT_CONF_PATH"

echo "✅ SSL paths patched in $DEFAULT_CONF_PATH"

echo "🔨 Rebuilding and restarting nginx container..."
cd "$HOME/jeffops_lab/containers"
docker compose build web
docker compose restart web

echo "✅ NGINX container restarted. Checking logs..."
docker compose logs web --tail=20
