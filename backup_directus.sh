#!/bin/bash

# 📁 Backup directory
BACKUP_DIR="/home/ubuntu/backups/directus"
DB_CONTAINER="directus"
DB_PATH_IN_CONTAINER="/directus/database/data.db"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_FILE="$BACKUP_DIR/data_$TIMESTAMP.db.gz"

# ✅ Ensure backup directory exists
mkdir -p "$BACKUP_DIR"

# 📦 Copy and compress the database file from the container
docker cp "$DB_CONTAINER:$DB_PATH_IN_CONTAINER" - | gzip > "$BACKUP_FILE"

# 🧹 Remove backups older than 7 days
find "$BACKUP_DIR" -type f -name "*.db.gz" -mtime +7 -exec rm {} \;
