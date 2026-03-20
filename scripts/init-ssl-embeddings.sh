#!/bin/bash
set -euo pipefail

DOMAIN="${1:?Usage: $0 <domain> <email>}"
EMAIL="${2:?Usage: $0 <domain> <email>}"
DEPLOY_DIR="/opt/pangolin"
EMBEDDINGS_COMPOSE="${DEPLOY_DIR}/docker/docker-compose.embeddings.yml"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

CERT_DIR="/etc/letsencrypt/live/${DOMAIN}"

# Step 1: Create dummy certificate so nginx can start
if [ ! -f "${CERT_DIR}/fullchain.pem" ]; then
    log "Creating dummy certificate for initial nginx startup..."
    mkdir -p "$CERT_DIR"
    openssl req -x509 -nodes -newkey rsa:2048 -days 1 \
        -keyout "${CERT_DIR}/privkey.pem" \
        -out "${CERT_DIR}/fullchain.pem" \
        -subj "/CN=localhost"
fi

# Step 2: Start nginx
log "Starting nginx..."
docker compose -f "$EMBEDDINGS_COMPOSE" up -d nginx

# Step 3: Get real certificate
log "Requesting real certificate for ${DOMAIN}..."
docker compose -f "$EMBEDDINGS_COMPOSE" run --rm certbot \
    certbot certonly \
    --webroot \
    --webroot-path=/var/www/certbot \
    --email "$EMAIL" \
    --agree-tos \
    --no-eff-email \
    --force-renewal \
    -d "$DOMAIN"

# Step 4: Reload nginx with real certificate
log "Reloading nginx with real certificate..."
docker compose -f "$EMBEDDINGS_COMPOSE" exec nginx nginx -s reload

log "SSL setup complete for ${DOMAIN}!"
