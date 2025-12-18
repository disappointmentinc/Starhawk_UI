#!/bin/bash
# NPM Diagnostic Script - Check current configuration

echo "========================================="
echo "NPM Configuration Diagnostic"
echo "========================================="
echo ""

echo "[1/4] Checking NPM container status..."
if docker ps | grep -q nginx-proxy-manager; then
    echo "✓ NPM container is running"
else
    echo "✗ NPM container is NOT running!"
    echo "  Start with: docker start nginx-proxy-manager"
    exit 1
fi
echo ""

echo "[2/4] Checking proxy host configurations..."
echo ""

# Get all proxy hosts from database
docker exec nginx-proxy-manager sqlite3 /data/database.sqlite <<EOF | while IFS='|' read -r domain scheme host port websockets ssl_forced; do
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Domain: $domain"
    echo "  Scheme: $scheme (forwarding to: $scheme://$host:$port)"
    echo "  Websockets: $([ "$websockets" == "1" ] && echo "✓ Enabled" || echo "✗ Disabled")"
    echo "  Force SSL: $([ "$ssl_forced" == "1" ] && echo "✓ Enabled" || echo "✗ Disabled")"

    # Check if settings are correct based on service
    if [[ "$domain" == *"n8n"* ]]; then
        [ "$scheme" == "http" ] || echo "  ⚠ WARNING: Should be 'http' not '$scheme'"
        [ "$websockets" == "1" ] || echo "  ⚠ WARNING: Websockets should be enabled"
    elif [[ "$domain" == *"portainer"* ]]; then
        [ "$scheme" == "https" ] || echo "  ⚠ WARNING: Should be 'https' not '$scheme'"
        [ "$port" == "9443" ] || echo "  ⚠ WARNING: Port should be 9443, not $port"
        [ "$websockets" == "1" ] || echo "  ⚠ WARNING: Websockets should be enabled"
    elif [[ "$domain" == *"proxmox"* ]]; then
        [ "$scheme" == "https" ] || echo "  ⚠ WARNING: Should be 'https' not '$scheme'"
        [ "$port" == "8006" ] || echo "  ⚠ WARNING: Port should be 8006, not $port"
        [ "$websockets" == "1" ] || echo "  ⚠ WARNING: Websockets should be enabled"
    elif [[ "$domain" == *"grafana"* || "$domain" == *"prometheus"* || "$domain" == *"cadvisor"* || "$domain" == *"moxie"* ]]; then
        [ "$scheme" == "http" ] || echo "  ⚠ WARNING: Should be 'http' not '$scheme'"
    elif [[ "$domain" == *"uptime"* ]]; then
        [ "$scheme" == "http" ] || echo "  ⚠ WARNING: Should be 'http' not '$scheme'"
        [ "$websockets" == "1" ] || echo "  ⚠ WARNING: Websockets should be enabled"
    elif [[ "$domain" == *"starhawk"* ]]; then
        [ "$scheme" == "https" ] || echo "  ⚠ WARNING: Should be 'https' not '$scheme'"
        [ "$websockets" == "1" ] || echo "  ⚠ WARNING: Websockets should be enabled"
    fi

    [ "$ssl_forced" == "1" ] || echo "  ⚠ WARNING: Force SSL should be enabled"
done
.mode list
SELECT
    domain_names,
    forward_scheme,
    forward_host,
    forward_port,
    allow_websocket_upgrade,
    ssl_forced
FROM proxy_host
WHERE is_deleted = 0
ORDER BY domain_names;
EOF

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "[3/4] Checking backend services..."
echo ""

services=(
    "n8n:5678"
    "grafana:3000"
    "portainer:9443"
    "prometheus:9090"
    "uptime:3001"
    "cadvisor:8080"
    "proxmox:8006"
)

for service in "${services[@]}"; do
    name="${service%%:*}"
    port="${service##*:}"
    echo -n "Checking $name on port $port... "

    if nc -z -w 2 145.223.73.242 "$port" 2>/dev/null; then
        echo "✓ Listening"
    else
        echo "✗ Not responding (service may not be running)"
    fi
done

echo ""

echo "[4/4] Testing HTTPS endpoints..."
echo ""

domains=(
    "n8n.cyberspace.business"
    "grafana.cyberspace.business"
    "portainer.cyberspace.business"
    "prometheus.cyberspace.business"
    "uptime.cyberspace.business"
    "proxmox.cyberspace.business"
)

for domain in "${domains[@]}"; do
    echo -n "Testing https://$domain... "
    status=$(curl -s -o /dev/null -w "%{http_code}" -k "https://$domain" --connect-timeout 5 2>/dev/null || echo "TIMEOUT")

    case $status in
        200|302|401|403)
            echo "✓ OK ($status)"
            ;;
        502)
            echo "✗ Bad Gateway (check backend service + scheme setting)"
            ;;
        503)
            echo "✗ Service Unavailable (backend not running?)"
            ;;
        504)
            echo "✗ Gateway Timeout (increase proxy timeouts or check backend)"
            ;;
        TIMEOUT)
            echo "⚠ Connection timeout (DNS or NPM issue?)"
            ;;
        *)
            echo "⚠ Unexpected status: $status"
            ;;
    esac
done

echo ""
echo "========================================="
echo "Diagnostic Complete"
echo "========================================="
echo ""
echo "If you see warnings above, run the fix script:"
echo "  bash fix_npm_config.sh"
echo ""
echo "Or fix manually via NPM web UI:"
echo "  http://145.223.73.242:81"
echo ""
