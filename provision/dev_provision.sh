#!/usr/bin/env bash
set -euxo pipefail
REPO_URL="$1"

# Clone app for development/testing
sudo -u vagrant bash -lc "mkdir -p ~/app && cd ~/app && \
  if [ ! -d .git ]; then git clone ${REPO_URL} .; fi"

# If the repo doesn't ship docker assets, drop in sane defaults so the demo works.
APP_DIR="/home/vagrant/app"
if [ ! -f "${APP_DIR}/Dockerfile" ]; then
  cp /vagrant/templates/Dockerfile "${APP_DIR}/Dockerfile"
fi
if [ ! -f "${APP_DIR}/docker-compose.dev.yml" ]; then
  cp /vagrant/templates/docker-compose.dev.yml "${APP_DIR}/docker-compose.dev.yml"
fi
if [ ! -f "${APP_DIR}/.env" ] && [ -f /vagrant/templates/.env.sample ]; then
  cp /vagrant/templates/.env.sample "${APP_DIR}/.env"
fi

# Build and run the dev stack
sudo -u vagrant bash -lc "cd ~/app && docker compose -f docker-compose.dev.yml up -d --build"

# Try to run tests if a common command exists (non-fatal)
set +e
sudo -u vagrant bash -lc "cd ~/app && \
  if [ -f package.json ] && jq -e '.scripts.test' package.json >/dev/null 2>&1; then \
    docker compose -f docker-compose.dev.yml exec -T app npm test || true; \
  elif [ -f 'pytest.ini' ] || ls -1 tests/*.py >/dev/null 2>&1; then \
    docker compose -f docker-compose.dev.yml exec -T app pytest || true; \
  else \
    echo 'No test command detected; skipping.'; \
  fi"
set -e
