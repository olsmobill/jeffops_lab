#!/bin/bash

BACKUP_DIR="/home/ubuntu/jeffops_lab/backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_NAME="directus_data_backup_${TIMESTAMP}.tar.gz"

echo "📦 Backing up Directus data volume..."
mkdir -p "$BACKUP_DIR"
docker run --rm -v containers_directus_data:/directus_data -v "$BACKUP_DIR":/backup alpine \
  tar czf /backup/"$BACKUP_NAME" -C /directus_data .
echo "✅ Backup complete: ${BACKUP_DIR}/${BACKUP_NAME}"
