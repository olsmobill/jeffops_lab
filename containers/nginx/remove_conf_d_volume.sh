#!/bin/bash

YML_FILE="docker-compose.yml"

# Backup the original just in case
cp "$YML_FILE" "${YML_FILE}.bak"

# Remove or comment out only the conf.d volume line under web service
awk '
/^  web:/ { in_web = 1 }
in_web && /conf\.d.*\/etc\/nginx\/conf\.d/ { next }  # skip line
{ print }
' "$YML_FILE" > temp.yml && mv temp.yml "$YML_FILE"

echo "✅ Removed conf.d volume line from web service in $YML_FILE"
