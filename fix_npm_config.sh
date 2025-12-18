#!/bin/bash
# NPM Configuration Fix Script
# This script updates Nginx Proxy Manager database to fix all proxy host configurations

set -e

echo "========================================="
echo "NPM Configuration Fix Script"
echo "========================================="
echo ""

# Backup the database first
echo "[1/5] Creating backup of NPM database..."
docker exec nginx-proxy-manager cp /data/database.sqlite /data/database.sqlite.backup.$(date +%Y%m%d_%H%M%S)
echo "✓ Backup created"
echo ""

# Update n8n.cyberspace.business
echo "[2/5] Fixing n8n.cyberspace.business..."
docker exec nginx-proxy-manager sqlite3 /data/database.sqlite <<EOF
UPDATE proxy_host
SET forward_scheme = 'http',
    forward_host = '145.223.73.242',
    forward_port = 5678,
    allow_websocket_upgrade = 1,
    block_exploits = 1,
    ssl_forced = 1,
    http2_support = 1,
    advanced_config = 'proxy_set_header Upgrade \$http_upgrade;
proxy_set_header Connection "upgrade";
proxy_set_header Host \$host;
proxy_set_header X-Real-IP \$remote_addr;
proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
proxy_set_header X-Forwarded-Proto \$scheme;
proxy_read_timeout 86400;
client_max_body_size 50M;'
WHERE domain_names LIKE '%n8n.cyberspace.business%';
EOF
echo "✓ n8n configured"

# Update grafana.cyberspace.business
echo "Fixing grafana.cyberspace.business..."
docker exec nginx-proxy-manager sqlite3 /data/database.sqlite <<EOF
UPDATE proxy_host
SET forward_scheme = 'http',
    forward_host = '145.223.73.242',
    forward_port = 3000,
    allow_websocket_upgrade = 1,
    block_exploits = 1,
    ssl_forced = 1,
    http2_support = 1,
    advanced_config = 'proxy_set_header Host \$host;
proxy_set_header X-Real-IP \$remote_addr;
proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
proxy_set_header X-Forwarded-Proto \$scheme;'
WHERE domain_names LIKE '%grafana.cyberspace.business%';
EOF
echo "✓ grafana configured"

# Update portainer.cyberspace.business
echo "Fixing portainer.cyberspace.business..."
docker exec nginx-proxy-manager sqlite3 /data/database.sqlite <<EOF
UPDATE proxy_host
SET forward_scheme = 'https',
    forward_host = '145.223.73.242',
    forward_port = 9443,
    allow_websocket_upgrade = 1,
    block_exploits = 1,
    ssl_forced = 1,
    http2_support = 1,
    advanced_config = 'proxy_set_header Upgrade \$http_upgrade;
proxy_set_header Connection "upgrade";
proxy_set_header Host \$host;
proxy_set_header X-Real-IP \$remote_addr;
proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
proxy_set_header X-Forwarded-Proto \$scheme;
proxy_ssl_verify off;'
WHERE domain_names LIKE '%portainer.cyberspace.business%';
EOF
echo "✓ portainer configured"

# Update prometheus.cyberspace.business
echo "Fixing prometheus.cyberspace.business..."
docker exec nginx-proxy-manager sqlite3 /data/database.sqlite <<EOF
UPDATE proxy_host
SET forward_scheme = 'http',
    forward_host = '145.223.73.242',
    forward_port = 9090,
    block_exploits = 1,
    ssl_forced = 1,
    http2_support = 1
WHERE domain_names LIKE '%prometheus.cyberspace.business%';
EOF
echo "✓ prometheus configured"

# Update uptime.cyberspace.business
echo "Fixing uptime.cyberspace.business..."
docker exec nginx-proxy-manager sqlite3 /data/database.sqlite <<EOF
UPDATE proxy_host
SET forward_scheme = 'http',
    forward_host = '145.223.73.242',
    forward_port = 3001,
    allow_websocket_upgrade = 1,
    block_exploits = 1,
    ssl_forced = 1,
    http2_support = 1,
    advanced_config = 'proxy_set_header Upgrade \$http_upgrade;
proxy_set_header Connection "upgrade";
proxy_set_header Host \$host;'
WHERE domain_names LIKE '%uptime.cyberspace.business%';
EOF
echo "✓ uptime configured"

# Update starhawk.cyberspace.business
echo "Fixing starhawk.cyberspace.business..."
docker exec nginx-proxy-manager sqlite3 /data/database.sqlite <<EOF
UPDATE proxy_host
SET forward_scheme = 'https',
    forward_host = '145.223.73.242',
    forward_port = 21371,
    allow_websocket_upgrade = 1,
    block_exploits = 1,
    ssl_forced = 1,
    http2_support = 1,
    advanced_config = 'proxy_ssl_verify off;'
WHERE domain_names LIKE '%starhawk.cyberspace.business%';
EOF
echo "✓ starhawk configured"

# Update moxie.cyberspace.business
echo "Fixing moxie.cyberspace.business..."
docker exec nginx-proxy-manager sqlite3 /data/database.sqlite <<EOF
UPDATE proxy_host
SET forward_scheme = 'http',
    forward_host = '145.223.73.242',
    forward_port = 1372,
    block_exploits = 1,
    ssl_forced = 1,
    http2_support = 1
WHERE domain_names LIKE '%moxie.cyberspace.business%';
EOF
echo "✓ moxie configured"

# Update cadvisor.cyberspace.business
echo "Fixing cadvisor.cyberspace.business..."
docker exec nginx-proxy-manager sqlite3 /data/database.sqlite <<EOF
UPDATE proxy_host
SET forward_scheme = 'http',
    forward_host = '145.223.73.242',
    forward_port = 8080,
    block_exploits = 1,
    ssl_forced = 1,
    http2_support = 1
WHERE domain_names LIKE '%cadvisor.cyberspace.business%';
EOF
echo "✓ cadvisor configured"

# Update/Create proxmox.cyberspace.business
echo "Fixing proxmox.cyberspace.business..."
docker exec nginx-proxy-manager sqlite3 /data/database.sqlite <<EOF
UPDATE proxy_host
SET forward_scheme = 'https',
    forward_host = '145.223.73.242',
    forward_port = 8006,
    allow_websocket_upgrade = 1,
    block_exploits = 1,
    ssl_forced = 1,
    http2_support = 1,
    advanced_config = 'proxy_set_header Upgrade \$http_upgrade;
proxy_set_header Connection "upgrade";
proxy_set_header Host \$host;
proxy_set_header X-Real-IP \$remote_addr;
proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
proxy_set_header X-Forwarded-Proto \$scheme;
proxy_ssl_verify off;
proxy_read_timeout 3600;
proxy_connect_timeout 3600;
proxy_send_timeout 3600;'
WHERE domain_names LIKE '%proxmox.cyberspace.business%';
EOF
echo "✓ proxmox configured"
echo ""

# Restart NPM to apply changes
echo "[3/5] Restarting Nginx Proxy Manager..."
docker restart nginx-proxy-manager
echo "✓ NPM restarted"
echo ""

# Wait for NPM to come back up
echo "[4/5] Waiting for NPM to start (30 seconds)..."
sleep 30
echo "✓ NPM should be up now"
echo ""

# Test the services
echo "[5/5] Testing services..."
echo ""

services=(
    "n8n.cyberspace.business"
    "grafana.cyberspace.business"
    "portainer.cyberspace.business"
    "prometheus.cyberspace.business"
    "uptime.cyberspace.business"
    "starhawk.cyberspace.business"
    "moxie.cyberspace.business"
    "cadvisor.cyberspace.business"
    "proxmox.cyberspace.business"
)

for service in "${services[@]}"; do
    echo -n "Testing $service... "
    status=$(curl -s -o /dev/null -w "%{http_code}" -k "https://$service" --connect-timeout 10 || echo "TIMEOUT")

    if [[ "$status" == "200" || "$status" == "302" || "$status" == "401" ]]; then
        echo "✓ OK ($status)"
    elif [[ "$status" == "TIMEOUT" ]]; then
        echo "⚠ TIMEOUT (service might not be running)"
    else
        echo "✗ FAILED ($status)"
    fi
done

echo ""
echo "========================================="
echo "Configuration Update Complete!"
echo "========================================="
echo ""
echo "Next steps:"
echo "1. Access NPM at: http://145.223.73.242:81"
echo "2. Login with: cyberspacebusinessceo@gmail.com"
echo "3. Check 'Hosts' > 'Proxy Hosts' to verify settings"
echo "4. Test each service in your browser"
echo ""
echo "If any service shows TIMEOUT, it might not be running."
echo "Check with: docker ps | grep <service-name>"
echo ""
