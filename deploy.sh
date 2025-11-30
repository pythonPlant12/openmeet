#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Load environment variables
source .env

DOMAIN="${DOMAIN:-openmeets.eu}"
EMAIL="${SSL_EMAIL:-admin@openmeets.eu}"

echo "=== OpenMeet Deployment ==="
echo "Domain: $DOMAIN"

# Check .env files exist
if [ ! -f ".env" ]; then
    echo "Error: .env file not found. Copy .env.example to .env and configure."
    exit 1
fi

if [ ! -f "openmeet-client/.env" ]; then
    echo "Error: openmeet-client/.env not found."
    exit 1
fi

if [ ! -f "openmeet-server/.env" ]; then
    echo "Error: openmeet-server/.env not found."
    exit 1
fi

# Create required directories
echo "=== Creating directories ==="
mkdir -p deployment/nginx
mkdir -p deployment/coturn
mkdir -p openmeet/certbot/conf
mkdir -p openmeet/certbot/www
mkdir -p certs

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
