#!/bin/bash

YML=~/jeffops_lab/containers/docker-compose.yml
BACKUP_DIR=~/jeffops_lab/backups
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_FILE="${BACKUP_DIR}/docker-compose_backup_${TIMESTAMP}.yml"

echo "📦 Injecting healthchecks into $YML..."

# Step 1: Ensure backup directory exists
mkdir -p "$BACKUP_DIR"

# Step 2: Create timestamped backup
cp "$YML" "$BACKUP_FILE"
echo "🧾 Backup created at: $BACKUP_FILE"

# Step 3: Inject healthchecks
yq eval '
.services.directus.healthcheck = {
  "test": ["CMD", "wget", "--spider", "-q", "http://localhost:8055/server/health"],
  "interval": "30s",
  "timeout": "10s",
  "retries": 3
} |
.services.api.healthcheck = {
  "test": ["CMD", "curl", "-f", "http://localhost:3000/health"],
  "interval": "30s",
  "timeout": "10s",
  "retries": 3
} |
.services.frontend.healthcheck = {
  "test": ["CMD", "curl", "-f", "http://localhost:3000"],
  "interval": "30s",
  "timeout": "10s",
  "retries": 3
} |
.services.web.healthcheck = {
  "test": ["CMD", "curl", "-f", "http://localhost"],
  "interval": "30s",
  "timeout": "10s",
  "retries": 3
}
' "$YML" > /tmp/compose.tmp.yml && mv /tmp/compose.tmp.yml "$YML"

echo "✅ Healthchecks injected."

# Step 4: Restart Docker stack
cd ~/jeffops_lab/containers
echo "🔁 Restarting Docker stack..."
docker compose down && docker compose up -d

# Step 5: Show status
echo "📊 Checking health status..."
docker ps --format "table {{.Names}}\t{{.Status}}"
