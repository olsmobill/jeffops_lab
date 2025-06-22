#!/bin/bash

cd /home/ubuntu/jeffops_lab || exit 1
git pull origin main && docker compose -f containers/docker-compose.yml up -d
