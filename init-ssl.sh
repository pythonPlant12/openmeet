#!/bin/bash
set -e

DOMAIN="${DOMAIN:-openmeets.eu}"
EMAIL="${SSL_EMAIL:-admin@openmeets.eu}"

echo "=== SSL Certificate Setup for $DOMAIN ==="

# Create directories
mkdir -p openmeet/certbot/conf
mkdir -p openmeet/certbot/www

# Create temporary HTTP-only nginx config
cat > /tmp/nginx-init.conf << 'EOF'
server {
    listen 80;
    listen [::]:80;
    server_name openmeets.eu www.openmeets.eu sfu.openmeets.eu;

    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }

    location / {
        return 200 'Waiting for SSL...';
        add_header Content-Type text/plain;
    }
}
EOF

echo "=== Starting temporary nginx (HTTP only) ==="
sudo docker run -d --name nginx_temp \
    -p 80:80 \
    -v /tmp/nginx-init.conf:/etc/nginx/conf.d/default.conf:ro \
    -v "$(pwd)/openmeet/certbot/www:/var/www/certbot" \
    nginx:alpine

sleep 3

echo "=== Requesting SSL certificates ==="
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

echo "=== Stopping temporary nginx ==="
sudo docker stop nginx_temp
sudo docker rm nginx_temp

echo "=== Done! Certificates are in openmeet/certbot/conf/live/$DOMAIN/ ==="
echo "Now run: sudo docker compose up -d"
