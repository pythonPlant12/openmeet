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

# Deployment has exclusive use of this VPS. Compose project labels from prior
# releases cannot be trusted, so remove every remaining container before startup.
ALL_CONTAINER_IDS="$(sudo docker ps -aq)"
if [ -n "$ALL_CONTAINER_IDS" ]; then
    echo "=== Removing all remaining Docker containers ==="
    sudo docker stop $ALL_CONTAINER_IDS >/dev/null 2>&1 || true
    sudo docker rm $ALL_CONTAINER_IDS >/dev/null 2>&1 || true
fi

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
