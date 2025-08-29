#!/usr/bin/env bash
# Usage: deploy_todo.sh <image-tag>
set -euo pipefail

TAG="${1:-latest}"
APP_HOME="/opt/todoapp"

if [ ! -f "${APP_HOME}/.env.deploy" ]; then
  echo "Missing ${APP_HOME}/.env.deploy"
  exit 1
fi

# Update tag
sudo sed -i "s/^IMAGE_TAG=.*/IMAGE_TAG=${TAG}/" "${APP_HOME}/.env.deploy"

# Pull and restart
sudo --preserve-env=IMAGE_TAG,IMAGE_NAME bash -lc "cd ${APP_HOME} && \
  docker compose -f docker-compose.prod.yml --env-file .env.deploy pull && \
  docker compose -f docker-compose.prod.yml --env-file .env.deploy up -d"

echo "Deployed image tag=${TAG}"
