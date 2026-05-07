#!/usr/bin/env bash
# Manual deploy: rsync local code to staging, restart API container, show logs.
#
# Usage:    ./deploy.sh [--no-logs|--follow]
# Override: SERVER_HOST=user@host REMOTE_PATH=/path CONTAINER=name ./deploy.sh

set -euo pipefail

SERVER_HOST="${SERVER_HOST:-root@207.126.161.154}"
REMOTE_PATH="${REMOTE_PATH:-/opt/fitness-training-service/}"
CONTAINER="${CONTAINER:-fitness_svr}"

LOGS_MODE="tail"
case "${1:-}" in
  --no-logs)  LOGS_MODE="skip" ;;
  --follow|-f) LOGS_MODE="follow" ;;
  -h|--help)
    sed -n '2,5p' "$0" | sed 's/^# //;s/^#//'
    exit 0
    ;;
esac

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> rsync ${SCRIPT_DIR}/ -> ${SERVER_HOST}:${REMOTE_PATH}"
rsync -avz \
  --exclude='.git' \
  --exclude='__pycache__' \
  --exclude='*.pyc' \
  --exclude='.env' \
  --exclude='.venv' \
  --exclude='venv' \
  --exclude='.pytest_cache' \
  --exclude='.mypy_cache' \
  "${SCRIPT_DIR}/" "${SERVER_HOST}:${REMOTE_PATH}"

echo "==> restarting container '${CONTAINER}' on ${SERVER_HOST}"
ssh "${SERVER_HOST}" "docker restart ${CONTAINER}"

case "$LOGS_MODE" in
  skip)
    echo "==> done."
    ;;
  follow)
    echo "==> following logs (Ctrl+C to exit)"
    ssh "${SERVER_HOST}" "docker logs --tail 20 -f ${CONTAINER}"
    ;;
  tail)
    sleep 2
    echo "==> recent logs:"
    ssh "${SERVER_HOST}" "docker logs --tail 20 ${CONTAINER}"
    echo "==> done."
    ;;
esac
