#!/usr/bin/env bash
set -euo pipefail
DEBIAN_FRONTEND=noninteractive

token=$1

echo "Installing k3s server..."
sudo curl -sfL https://get.k3s.io | K3S_TOKEN=$token sh -

echo "Verifying k3s installation..."
sudo k3s kubectl cluster-info
