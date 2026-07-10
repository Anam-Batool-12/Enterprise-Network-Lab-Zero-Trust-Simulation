#!/bin/bash
set -e
LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "[*] Disabling UFW..."
ufw disable
echo "[*] Building network topology..."
bash "$LAB_DIR/setup-lab.sh"
echo "[*] Applying Zero Trust firewall policy..."
nft delete table inet zerotrust 2>/dev/null || true
nft -f "$LAB_DIR/nftables-rules.conf"
echo "[*] Starting SSH service in ns-corp..."
ip netns exec ns-corp mkdir -p /run/sshd
ip netns exec ns-corp bash -c "pkill sshd 2>/dev/null; sleep 1; /usr/sbin/sshd"
echo "[+] Lab fully ready."
