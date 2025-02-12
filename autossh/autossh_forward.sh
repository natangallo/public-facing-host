#!/bin/bash

CONFIG_FILE="hosts.txt"
REMOTE_USER="service-user"
REMOTE_HOST="your-host.duckdns.org"

terminate_existing_autossh_processes() {
    local port1="$1"
    local port2="$2"
    pids=$(pgrep -f "autossh .* -R $port1:.* -R $port2:.*")
    if [[ -n "$pids" ]]; then
        kill -9 $pids
    fi
}

while IFS=' ' read -r ip port1 port2; do
    if [[ -n "$ip" && -n "$port1" && -n "$port2" ]]; then
        terminate_existing_autossh_processes "$port1" "$port2"
        autossh -f -N -R "$port1:$ip:80" -R "$port2:$ip:443" \
            "$REMOTE_USER@$REMOTE_HOST" &
    fi
done < "$CONFIG_FILE"