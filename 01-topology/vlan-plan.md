# VLAN Plan (Final)

## Architecture
Network emulated using Linux network namespaces + virtual bridges 
(no dedicated VMs/hardware required).

| Segment | Subnet | Namespace | Bridge | Role |
|---------|--------|-----------|--------|------|
| VLAN 10 | 10.10.10.0/24 | ns-admin | br-vlan10 | Admin / attacker node |
| VLAN 20 | 10.10.20.0/24 | ns-corp | br-vlan20 | Corporate endpoint |
| VLAN 30 | 10.10.30.0/24 | ns-iot | br-vlan30 | IoT / CCTV endpoint |

## Zero Trust Policy
- Default: DROP all forwarded traffic
- Explicit allow: VLAN10 -> VLAN20, TCP/22 (SSH) only
- Everything else (including all VLAN30 traffic): blocked + logged

## Key Design Decision
Initial plan used separate VMs (VMware/VirtualBox) per segment. This 
was abandoned after cross-hypervisor networking incompatibility and 
repeated guest-OS compatibility issues (see troubleshooting-log.md). 
Final architecture uses namespace-based emulation on a single host, 
providing equivalent isolation with full reproducibility via 
start-lab.sh.
