#!/bin/bash

# Location: /home/ubuntu/jeffops_lab/harden_ssh.sh

SSH_CONFIG="/etc/ssh/sshd_config"
BACKUP="/etc/ssh/sshd_config.bak.$(date +%Y%m%d_%H%M%S)"

echo "📦 Backing up original SSH config to $BACKUP"
sudo cp "$SSH_CONFIG" "$BACKUP"

echo "🔧 Writing hardened SSH settings..."
sudo tee "$SSH_CONFIG" > /dev/null <<EOF
# Hardened SSH Configuration
Port 22
PermitRootLogin no
PasswordAuthentication no
ChallengeResponseAuthentication no
UsePAM yes
X11Forwarding no
AllowTcpForwarding no
MaxAuthTries 3
LoginGraceTime 30
ClientAliveInterval 300
ClientAliveCountMax 2
EOF

echo "🔄 Restarting SSH service..."
sudo systemctl restart sshd

echo "✅ SSH hardening complete. SSH service restarted."
