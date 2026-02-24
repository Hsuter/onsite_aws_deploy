#!/bin/bash
set -euo pipefail

apt-get update -y
apt-get install -y curl ca-certificates

# Ensure SSM agent is running (Ubuntu often has it, this makes it reliable)
snap install amazon-ssm-agent --classic || true
systemctl enable snap.amazon-ssm-agent.amazon-ssm-agent.service || true
systemctl restart snap.amazon-ssm-agent.amazon-ssm-agent.service || true

echo "SSM bootstrap complete" > /var/log/bootstrap.complete


