# Secure Remote Access with SSH Tunneling and HAProxy

## Overview

This guide describes how to securely expose local services to the internet using SSH tunneling and HAProxy, without requiring direct port forwarding through your firewall. This setup is particularly useful for hosting services like Nextcloud in environments where direct port forwarding is not possible or desired.

## Prerequisites

- A local server running your service (e.g., Nextcloud)
- A public host with a static IP or dynamic DNS service
- Basic understanding of Linux system administration
- SSH access to both local and remote servers

## Components

1. **Local Server**
   - OpenSSH Server
   - AutoSSH for persistent connections
   - Service user account

2. **Public Host**
   - HAProxy
   - OpenSSH Server
   - DuckDNS update agent
   - Service user account

## Setup Process

### 1. Local Server Configuration

#### 1.1 Create Service User
```bash
sudo adduser service-user
sudo usermod -aG sudo service-user
```

#### 1.2 Generate SSH Keys
```bash
su - service-user
ssh-keygen -t rsa -b 4096
```

### 2. Public Host Configuration

#### 2.1 Install Required Packages
```bash
sudo apt-get update
sudo apt-get install haproxy openssh-server
```

#### 2.2 Configure HAProxy
Create or modify `/etc/haproxy/haproxy.cfg`:

#### 2.3 DuckDNS Configuration

Create `/usr/duckdns/duck_update.sh`:

Add to crontab:
```bash
*/5 * * * * /usr/duckdns/duck_update.sh >/dev/null 2>&1
```

### 3. SSH Tunnel Configuration

#### 3.1 Create Tunnel Management Script
Create `~/autossh/autossh_forward.sh`:
```bash
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
```

## Security Considerations

- Use strong SSH keys (RSA 4096 bits minimum)
- Disable password authentication for SSH
- Keep systems and packages updated
- Implement proper firewall rules
- Monitor logs regularly
- Use SSL/TLS for all services

## References

- [HAProxy Documentation](http://www.haproxy.org/#docs)
- [OpenSSH Documentation](https://www.openssh.com/manual.html)
- [AutoSSH Manual](https://linux.die.net/man/1/autossh)
- [DuckDNS Documentation](https://www.duckdns.org/install.jsp)

## Notes

The following items are not covered in detail and should be considered during implementation:
1. Specific firewall configurations
2. Detailed SSL/TLS setup
3. Monitoring and alerting setup
4. Backup and recovery procedures
5. Load balancing considerations
6. High availability setup
7. Performance tuning

## License

This documentation is provided under the MIT License.
