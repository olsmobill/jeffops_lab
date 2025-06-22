#!/bin/bash

# Location: /home/ubuntu/jeffops_lab/containers/log_container_stats.sh
# Purpose: Log basic container resource stats to a local file

LOG_FILE="/home/ubuntu/monitor_stats.log"
TIMESTAMP=$(date -u +"[%Y-%m-%d %H:%M:%S UTC]")

echo "$TIMESTAMP Container Stats:" >> "$LOG_FILE"

docker stats --no-stream --format \
"{{.Name}} - CPU: {{.CPUPerc}}, Mem: {{.MemUsage}}, Net I/O: {{.NetIO}}" >> "$LOG_FILE"

echo "" >> "$LOG_FILE"
