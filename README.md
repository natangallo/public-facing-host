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
sudo apt-get install haproxy openssh-server -y
```

#### 2.2 Modify SSH Configuration
Edit `/etc/ssh/sshd_config` 
`PasswordAuthentication no
PermitRootLogin no
PubkeyAuthentication yes
AllowTcpForwarding yes
GatewayPorts yes`

Restart SSH service
`sudo systemctl restart ssh`

#### 2.3 Configure HAProxy
Create or modify `/etc/haproxy/haproxy.cfg`:
```bash
sudo nano /etc/haproxy/haproxy.cfg
```
Check HAProxy configuration file
```bash
sudo haproxy -c -f /etc/haproxy/haproxy.cfg
```
Restart HAProxy Service
```bash
sudo systemctl restart haproxy
```

#### 2.3 DuckDNS Configuration

Create `/usr/duckdns/duck_update.sh`:
```bash
sudo mkdir /usr/duckdns
sudo nano /usr/duckdns/duck_update.sh
sudo chmod +x /usr/duckdns/duck_update.sh
```

Add to crontab:
```bash
sudo crontab -e
*/5 * * * * /usr/duckdns/duck_update.sh >/dev/null 2>&1
```

### 3. SSH Tunnel Configuration

#### 3.1 Copy Public Key to public host server
Execute:
```bash
ssh-copy-id proxmox-service@ip_del_tuo_server_pubblico
```
Otherwise, manually copy the content of `id_rsa.pub` in `~/.ssh/authorized_keys`  file on the server:
```bash
mkdir -p ~/.ssh
echo "PUBLIC_KEY" >> ~/.ssh/authorized_keys
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

#### 3.2 Create Tunnel Management Script
Create `~/autossh/autossh_forward.sh`:
```bash
mkdir ~/autossh
nano ~/autossh/autossh_forward.sh
chmod +x ~/autossh/autossh_forward.sh
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
