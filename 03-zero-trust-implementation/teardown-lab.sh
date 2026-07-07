#!/bin/bash
echo "[*] Tearing down lab topology..."
ip netns del ns-corp 2>/dev/null
ip netns del ns-iot 2>/dev/null
ip link del br-vlan10 2>/dev/null
ip link del br-vlan20 2>/dev/null
ip link del br-vlan30 2>/dev/null
ip link del veth-kali 2>/dev/null
echo "[+] Cleaned up."
