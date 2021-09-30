#!/usr/bin/env bash
set -euo pipefail
DEBIAN_FRONTEND=noninteractive

hostname=$1

echo "=> Fixing /etc/hosts file..."
sudo sed -i "s/127.0.1.1.*/127.0.1.1  $hostname.$hostname  $hostname/" /etc/hosts
sudo hostnamectl set-hostname $hostname

echo "=> Running apt-get update..."
sudo apt-get update -qq
echo "=> Installing curl..."
sudo apt-get install -y -qq \
     curl > /dev/null
