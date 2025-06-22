#!/bin/bash

# === Configuration ===
MAIL_TO="you@example.com"
MAIL_SUBJECT_ALERT="🚨 JeffOps Alert: Unhealthy Docker Containers"
MAIL_SUBJECT_RECOVERY="✅ JeffOps: All Containers Healthy"
LOG_FILE="$HOME/monitor_history.log"
STATE_FILE="/tmp/jeffops_health_state"

# === Health Check ===
UNHEALTHY=$(docker ps --filter "health=unhealthy" --format "{{.Names}} - {{.Status}}")
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

# === Logging ===
echo "[$TIMESTAMP] Running health check..." >> "$LOG_FILE"
if [ -n "$UNHEALTHY" ]; then
    echo "[$TIMESTAMP] Unhealthy containers detected:" >> "$LOG_FILE"
    echo "$UNHEALTHY" >> "$LOG_FILE"

    # Only alert if not already unhealthy
    if [ ! -f "$STATE_FILE" ]; then
        echo -e "Unhealthy container(s) detected:\n\n$UNHEALTHY" | mail -s "$MAIL_SUBJECT_ALERT" "$MAIL_TO"
        touch "$STATE_FILE"
        echo "[$TIMESTAMP] Alert email sent." >> "$LOG_FILE"
    else
        echo "[$TIMESTAMP] Already alerted. Skipping duplicate email." >> "$LOG_FILE"
    fi
else
    echo "[$TIMESTAMP] All containers healthy." >> "$LOG_FILE"

    # If previously unhealthy, notify recovery
    if [ -f "$STATE_FILE" ]; then
        echo "All containers are now healthy again." | mail -s "$MAIL_SUBJECT_RECOVERY" "$MAIL_TO"
        rm -f "$STATE_FILE"
        echo "[$TIMESTAMP] Recovery email sent." >> "$LOG_FILE"
    fi
fi
