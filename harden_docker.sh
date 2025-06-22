#!/bin/bash

# Location: /home/ubuntu/jeffops_lab/harden_docker.sh

DOCKER_DAEMON_JSON="/etc/docker/daemon.json"
BACKUP="/etc/docker/daemon.json.bak.$(date +%Y%m%d_%H%M%S)"

echo "📦 Backing up current Docker config to $BACKUP"
if [ -f "$DOCKER_DAEMON_JSON" ]; then
  sudo cp "$DOCKER_DAEMON_JSON" "$BACKUP"
else
  echo "{}" | sudo tee "$DOCKER_DAEMON_JSON" > /dev/null
fi

echo "🔐 Writing secure Docker daemon settings..."

sudo tee "$DOCKER_DAEMON_JSON" > /dev/null <<EOF
{
  "no-new-privileges": true,
  "live-restore": true,
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "userns-remap": "default"
}
EOF

echo "🔄 Restarting Docker to apply changes..."
sudo systemctl restart docker

echo "✅ Docker hardening complete."
