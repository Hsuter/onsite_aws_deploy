#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

# --- Packages ---
apt-get update -y
apt-get install -y nginx docker.io git

systemctl enable --now docker
systemctl enable --now nginx

# --- Run a test upstream container on localhost:3000 (idempotent) ---
docker rm -f webtest >/dev/null 2>&1 || true
docker run -d --name webtest -p 127.0.0.1:3000:80 nginx:alpine

# --- Nginx reverse proxy to localhost:3000 ---
cat >/etc/nginx/sites-available/remake <<'EOF'
server {
  listen 80;
  server_name _;

  location / {
    proxy_pass http://127.0.0.1:3000;
    proxy_http_version 1.1;

    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
  }
}
EOF

rm -f /etc/nginx/sites-enabled/default
ln -sf /etc/nginx/sites-available/remake /etc/nginx/sites-enabled/remake

nginx -t
systemctl reload nginx

# --- Quick health checks ---
curl -fsS http://127.0.0.1:3000 >/dev/null
curl -fsS http://127.0.0.1 >/dev/null

echo "Configure complete" > /var/log/configure.complete
