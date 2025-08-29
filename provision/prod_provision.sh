#!/usr/bin/env bash
set -euxo pipefail
DOCKERHUB_REPO="$1"

APP_HOME="/opt/todoapp"
sudo mkdir -p "${APP_HOME}/data"
sudo chown -R vagrant:vagrant "${APP_HOME}"

# Place prod compose + env
cp /vagrant/templates/docker-compose.prod.yml "${APP_HOME}/docker-compose.prod.yml"
cp /vagrant/templates/.env.sample "${APP_HOME}/.env"
# Default image reference (can be overridden later by deploy.sh)
echo "IMAGE_NAME=${DOCKERHUB_REPO}" | sudo tee "${APP_HOME}/.env.deploy" >/dev/null
echo "IMAGE_TAG=latest" | sudo tee -a "${APP_HOME}/.env.deploy" >/dev/null

# Deploy script
cp /vagrant/provision/deploy.sh /usr/local/bin/deploy_todo.sh
chmod +x /usr/local/bin/deploy_todo.sh

# systemd unit for automatic start
sudo tee /etc/systemd/system/todoapp.service >/dev/null <<'UNIT'
[Unit]
Description=Todo App (Docker Compose)
After=network-online.target docker.service
Wants=network-online.target
Requires=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/opt/todoapp
EnvironmentFile=/opt/todoapp/.env.deploy
ExecStart=/usr/bin/docker compose -f /opt/todoapp/docker-compose.prod.yml --env-file /opt/todoapp/.env.deploy up -d
ExecStop=/usr/bin/docker compose -f /opt/todoapp/docker-compose.prod.yml --env-file /opt/todoapp/.env.deploy down
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
UNIT

sudo systemctl daemon-reload
sudo systemctl enable --now todoapp.service || true

echo "Use: sudo deploy_todo.sh <tag>  # e.g., dev-latest or a Git tag"
