#!/bin/bash
# Enterprise Network Lab - Topology Setup Script
# Run with: sudo bash setup-lab.sh

echo "[*] Creating VLAN bridges..."
ip link add br-vlan10 type bridge
ip link add br-vlan20 type bridge
ip link add br-vlan30 type bridge
ip link set br-vlan10 up
ip link set br-vlan20 up
ip link set br-vlan30 up
ip addr add 10.10.10.1/24 dev br-vlan10
ip addr add 10.10.20.1/24 dev br-vlan20
ip addr add 10.10.30.1/24 dev br-vlan30

echo "[*] Creating VLAN20 (corp) namespace..."
ip netns add ns-corp
ip link add veth-corp type veth peer name veth-corp-br
ip link set veth-corp netns ns-corp
ip link set veth-corp-br master br-vlan20
ip link set veth-corp-br up
ip netns exec ns-corp ip addr add 10.10.20.50/24 dev veth-corp
ip netns exec ns-corp ip link set veth-corp up
ip netns exec ns-corp ip link set lo up
ip netns exec ns-corp ip route add default via 10.10.20.1

echo "[*] Creating VLAN30 (iot) namespace..."
ip netns add ns-iot
ip link add veth-iot type veth peer name veth-iot-br
ip link set veth-iot netns ns-iot
ip link set veth-iot-br master br-vlan30
ip link set veth-iot-br up
ip netns exec ns-iot ip addr add 10.10.30.50/24 dev veth-iot
ip netns exec ns-iot ip link set veth-iot up
ip netns exec ns-iot ip link set lo up
ip netns exec ns-iot ip route add default via 10.10.30.1

echo "[*] Creating VLAN10 (admin/Kali) namespace..."
ip netns add ns-admin
ip link add veth-kali type veth peer name veth-kali-br
ip link set veth-kali netns ns-admin
ip link set veth-kali-br master br-vlan10
ip link set veth-kali-br up
ip netns exec ns-admin ip addr add 10.10.10.50/24 dev veth-kali
ip netns exec ns-admin ip link set veth-kali up
ip netns exec ns-admin ip link set lo up
ip netns exec ns-admin ip route add default via 10.10.10.1

echo "[*] Enabling IP forwarding..."
sysctl -w net.ipv4.ip_forward=1

echo "[+] Lab topology ready. Run 'ping 10.10.20.50' or 'ping 10.10.30.50' to test."
