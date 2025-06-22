#!/bin/bash

LOGFILE="/home/ubuntu/jeffops_lab/redeploy.log"
echo "📦 Redeploy triggered at $(date)" >> "$LOGFILE"

cd /home/ubuntu/jeffops_lab || exit 1

echo "🔄 Pulling latest code..." >> "$LOGFILE"
git pull origin main >> "$LOGFILE" 2>&1

echo "🐳 Rebuilding and restarting containers..." >> "$LOGFILE"
docker compose -f containers/docker-compose.yml down >> "$LOGFILE" 2>&1
docker compose -f containers/docker-compose.yml up -d --build >> "$LOGFILE" 2>&1

echo "✅ Redeploy complete at $(date)" >> "$LOGFILE"

