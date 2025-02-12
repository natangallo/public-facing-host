#!/bin/bash
CONFIG_FILE="duckdns_config.txt"
LOG_DIR="/usr/duckdns"
LOG_FILE="$LOG_DIR/duck.log"
DUCKDNS_URL="https://www.duckdns.org/update"

mkdir -p "$LOG_DIR"

while IFS=' ' read -r domain token; do
    if [[ -n "$domain" && -n "$token" ]]; then
        curl -k -o "$LOG_FILE" "$DUCKDNS_URL?domains=$domain&token=$token&ip="
    fi
done < "$CONFIG_FILE"
