#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Check .env files exist
if [ ! -f ".env" ]; then
    echo "Error: .env file not found. Copy .env.example to .env and configure."
    exit 1
fi

# Load environment variables and export them for deployment helper scripts.
set -a
source .env
set +a

DOMAIN="${DOMAIN:-openmeets.eu}"
EMAIL="${SSL_EMAIL:-admin@openmeets.eu}"

echo "=== OpenMeet Deployment ==="
echo "Domain: $DOMAIN"

if [ ! -f "openmeet-client/.env" ]; then
    echo "Error: openmeet-client/.env not found."
    exit 1
fi

if [ ! -f "openmeet-server/.env" ]; then
    echo "Error: openmeet-server/.env not found."
    exit 1
fi

# Configure the host firewall before containers start publishing ports.
chmod +x deployment/configure-ufw.sh
deployment/configure-ufw.sh

# Create required directories
echo "=== Creating directories ==="
mkdir -p deployment/nginx
mkdir -p deployment/coturn
mkdir -p openmeet/certbot/conf
mkdir -p openmeet/certbot/www
mkdir -p certs

# The compose file uses an external named network so `docker compose down` and
# Docker pruning cannot leave stale containers referencing a deleted network.
echo "=== Ensuring Docker network exists ==="
if ! sudo docker network inspect openmeet_network >/dev/null 2>&1; then
    sudo docker network create openmeet_network >/dev/null
fi

# Check if SSL certificates exist
CERT_PATH="openmeet/certbot/conf/live/$DOMAIN"
if [ ! -d "$CERT_PATH" ]; then
    echo "=== SSL certificates not found, requesting new ones ==="

    # Start nginx temporarily for ACME challenge
    sudo docker compose up -d nginx
    sleep 5

    # Request certificates
    sudo docker run --rm \
        -v "$(pwd)/openmeet/certbot/conf:/etc/letsencrypt" \
        -v "$(pwd)/openmeet/certbot/www:/var/www/certbot" \
        certbot/certbot certonly \
        --webroot \
        --webroot-path=/var/www/certbot \
        --email "$EMAIL" \
        --agree-tos \
        --no-eff-email \
        -d "$DOMAIN" \
        -d "www.$DOMAIN" \
        -d "sfu.$DOMAIN"

    echo "[OK] SSL certificates obtained"
else
    echo "[OK] SSL certificates found"
fi

# Stop existing containers
echo "=== Stopping existing containers ==="
sudo docker compose down --remove-orphans || true

# Compose project names have changed over time on this VPS, and some services use
# fixed container_name values. Remove stale Docker containers that can keep ports
# bound even after `docker compose down --remove-orphans` misses them.
echo "=== Clearing Docker port conflicts ==="
KNOWN_CONTAINERS=(
    grafana
    openmeet_nginx
    openmeet_sfu
    openmeet_postgres
    loki
    cadvisor
    openmeet_coturn
    openmeet_certbot
    promtail
    prometheus
    openmeet_frontend
    node-exporter
)

for container in "${KNOWN_CONTAINERS[@]}"; do
    if sudo docker ps -a --format '{{.Names}}' | grep -Fxq "$container"; then
        echo "Removing stale container: $container"
        sudo docker rm -f "$container" >/dev/null 2>&1 || true
    fi
done

REQUIRED_PORTS=(80 443 3000 3100 8080 9080 9090 9100)

for port in "${REQUIRED_PORTS[@]}"; do
    conflicting_containers="$(sudo docker ps --filter "publish=$port" --format '{{.Names}}')"
    if [ -n "$conflicting_containers" ]; then
        echo "Removing Docker containers using port $port:"
        echo "$conflicting_containers"
        while IFS= read -r container; do
            [ -n "$container" ] && sudo docker rm -f "$container" >/dev/null 2>&1 || true
        done <<< "$conflicting_containers"
    fi
done

# Build and start services
echo "=== Building services ==="
sudo docker compose build

echo "=== Starting services ==="
sudo docker compose up -d

# Wait for services
echo "=== Waiting for services to start ==="
sleep 10

# Health check
echo "=== Health Check ==="
if sudo docker compose ps | grep -q "Up"; then
    echo "[OK] Services are running"
    sudo docker compose ps
else
    echo "[FAIL] Some services failed to start"
    sudo docker compose logs --tail=50
    exit 1
fi

echo "=== Deployment complete ==="
