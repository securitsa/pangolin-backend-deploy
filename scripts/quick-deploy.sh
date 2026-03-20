#!/bin/bash
set -euo pipefail

DEPLOY_DIR="/opt/pangolin"
ENV_FILE="${DEPLOY_DIR}/.env"
COMPOSE="${DEPLOY_DIR}/docker/docker-compose.yml"

cd "$DEPLOY_DIR"

echo "Pulling latest images..."
docker compose -f "$COMPOSE" --env-file "$ENV_FILE" pull \
  dialogue-service identity-service pulse-service semantic-hub-service prediction-hub-service

echo "Restarting services..."
docker compose -f "$COMPOSE" --env-file "$ENV_FILE" up -d --no-deps \
  dialogue-service identity-service pulse-service moderation-bot \
  semantic-hub-service semantic-hub-consumer \
  prediction-hub-service prediction-hub-consumer nginx

echo "Done:"
docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}"
