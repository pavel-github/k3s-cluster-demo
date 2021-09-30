#!/usr/bin/env bash
set -euo pipefail
DEBIAN_FRONTEND=noninteractive

token=$1
server_url=$2

echo "Installing k3s agent..."
sudo curl -sfL https://get.k3s.io | K3S_TOKEN=$token K3S_URL=https://$server_url:6443 sh -
