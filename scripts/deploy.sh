#!/bin/bash
set -euo pipefail

DEPLOY_DIR="/opt/pangolin"
ENV_FILE="${DEPLOY_DIR}/.env"
INFRA_COMPOSE="${DEPLOY_DIR}/docker/docker-compose.infra.yml"
APPS_COMPOSE="${DEPLOY_DIR}/docker/docker-compose.yml"

SERVICE="${1:-all}"
TAG="${2:-latest}"

cd "$DEPLOY_DIR"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

update_tag() {
    local svc_name="$1"
    local tag_var="$2"
    local new_tag="$3"
    sed -i "s/^${tag_var}=.*/${tag_var}=${new_tag}/" "$ENV_FILE"
    log "Updated ${tag_var}=${new_tag}"
}

deploy_service() {
    local svc="$1"
    local tag="$2"

    case "$svc" in
        dialogue-service)
            update_tag "$svc" "DIALOGUE_TAG" "$tag"
            ;;
        identity-service)
            update_tag "$svc" "IDENTITY_TAG" "$tag"
            ;;
        pulse-service)
            update_tag "$svc" "PULSE_TAG" "$tag"
            ;;
        *)
            log "ERROR: Unknown service: $svc"
            exit 1
            ;;
    esac

    log "Pulling image for ${svc}..."
    docker compose -f "$APPS_COMPOSE" --env-file "$ENV_FILE" pull "$svc"

    log "Restarting ${svc}..."
    docker compose -f "$APPS_COMPOSE" --env-file "$ENV_FILE" up -d --no-deps "$svc"

    log "Deployed ${svc}:${tag} successfully"
}

ensure_infra() {
    log "Ensuring infrastructure is running..."
    docker compose -f "$INFRA_COMPOSE" --env-file "$ENV_FILE" up -d
}

case "$SERVICE" in
    all)
        ensure_infra
        for svc in dialogue-service identity-service pulse-service; do
            deploy_service "$svc" "$TAG"
        done
        log "Restarting nginx..."
        docker compose -f "$APPS_COMPOSE" --env-file "$ENV_FILE" up -d --no-deps nginx
        ;;
    infra)
        ensure_infra
        ;;
    dialogue-service|identity-service|pulse-service)
        deploy_service "$SERVICE" "$TAG"
        ;;
    *)
        echo "Usage: $0 {all|infra|dialogue-service|identity-service|pulse-service} [tag]"
        exit 1
        ;;
esac

log "Deployment complete. Running containers:"
docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}"
