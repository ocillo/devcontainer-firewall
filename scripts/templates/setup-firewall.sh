#!/usr/bin/env bash
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "setup-firewall.sh must be run with sudo/root privileges." >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing firewall dependencies..."
apt-get update -y
DEBIAN_FRONTEND=noninteractive apt-get install -y \
  iptables \
  ipset \
  iproute2 \
  curl \
  dnsutils \
  jq

echo "Copying init-firewall.sh to /usr/local/bin..."
install -m 0755 "${SCRIPT_DIR}/init-firewall.sh" /usr/local/bin/init-firewall.sh

echo "Firewall setup complete."
