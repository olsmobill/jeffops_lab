#!/bin/bash
apt update -y
apt install -y docker.io docker-compose nginx ufw
ufw allow 'OpenSSH'
ufw allow 'Nginx Full'
ufw --force enable
systemctl enable docker
