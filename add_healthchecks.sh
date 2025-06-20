#!/bin/bash

# === Paths ===
DC_PATH="/home/ubuntu/jeffops_lab/containers/docker-compose.yml"
BACKUP_PATH="/home/ubuntu/jeffops_lab/containers/docker-compose.yml.bak_$(date +%Y%m%d_%H%M%S)"

# === Step 1: Backup ===
echo "📦 Backing up current docker-compose.yml to $BACKUP_PATH"
cp "$DC_PATH" "$BACKUP_PATH"

# === Step 2: Inject Health Checks ===
echo "🔧 Adding health checks to services..."

awk '
/^\s*api:$/ {
    print;
    in_api = 1;
    next;
}
/^\s*frontend:$/ {
    print;
    in_frontend = 1;
    next;
}
/^\s*directus:$/ {
    print;
    in_directus = 1;
    next;
}
/^\s*[a-z]+:$/ {
    in_api = in_frontend = in_directus = 0;
}
{
    print;
    if (in_api && /^\s*networks:/) {
        print "    healthcheck:";
        print "      test: [\"CMD\", \"curl\", \"-f\", \"http://localhost:3000\"]";
        print "      interval: 30s";
        print "      timeout: 10s";
        print "      retries: 3";
        in_api = 0;
    }
    if (in_frontend && /^\s*networks:/) {
        print "    healthcheck:";
        print "      test: [\"CMD\", \"curl\", \"-f\", \"http://localhost:3000\"]";
        print "      interval: 30s";
        print "      timeout: 10s";
        print "      retries: 3";
        in_frontend = 0;
    }
    if (in_directus && /^\s*networks:/) {
        print "    healthcheck:";
        print "      test: [\"CMD\", \"curl\", \"-f\", \"http://localhost:8055/server/health\"]";
        print "      interval: 30s";
        print "      timeout: 10s";
        print "      retries: 3";
        in_directus = 0;
    }
}
' "$BACKUP_PATH" > "$DC_PATH"

echo "✅ Health checks injected successfully."
