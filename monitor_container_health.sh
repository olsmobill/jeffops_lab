#!/bin/bash

timestamp=$(date +"%Y-%m-%d %H:%M:%S")
log_file="/var/log/docker_health.log"

mkdir -p $(dirname "$log_file")

echo "[$timestamp] 🔍 Checking container health..." >> "$log_file"

unhealthy=$(docker inspect --format '{{.Name}}: {{.State.Health.Status}}' $(docker ps -q) | grep -v 'healthy' | grep -v 'null')

if [ -n "$unhealthy" ]; then
  echo "[$timestamp] ❌ Unhealthy containers detected:" >> "$log_file"
  echo "$unhealthy" >> "$log_file"
else
  echo "[$timestamp] ✅ All containers healthy." >> "$log_file"
fi
