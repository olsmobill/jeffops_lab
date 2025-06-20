#!/bin/bash

NGINX_CONF="./nginx/default.conf"
DIRECTUS_ROUTE_BLOCK=$(cat <<'EOF'

    # Reverse proxy for Directus
    location /admin/ {
        proxy_pass http://directus:8055/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

EOF
)

echo "🔧 Patching NGINX config..."

# Only patch if not already present
if grep -q "location /admin/" "$NGINX_CONF"; then
    echo "✅ /admin block already exists. Skipping patch."
else
    # Insert before last closing brace in server block
    sed -i "/^\s*}\s*$/i $DIRECTUS_ROUTE_BLOCK" "$NGINX_CONF"
    echo "✅ /admin block added to NGINX config."
fi

echo "🔄 Rebuilding NGINX container..."

# Rebuild NGINX
docker-compose down && docker-compose up -d --build

echo "🚀 NGINX updated. Try visiting: http://3.210.232.161/admin/"
