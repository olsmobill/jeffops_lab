#!/bin/bash

LOG_FILE="/home/ubuntu/jeffops_lab/watchdog.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

echo "[$TIMESTAMP] Running JeffOps watchdog..." >> "$LOG_FILE"

# Get names of all unhealthy containers
UNHEALTHY=$(docker ps --filter "health=unhealthy" --format "{{.Names}}")

if [ -z "$UNHEALTHY" ]; then
  echo "[$TIMESTAMP] All containers healthy ✅" >> "$LOG_FILE"
else
  for container in $UNHEALTHY; do
    echo "[$TIMESTAMP] 🚨 Restarting unhealthy container: $container" >> "$LOG_FILE"
    docker restart "$container" >> "$LOG_FILE" 2>&1
  done
fi
