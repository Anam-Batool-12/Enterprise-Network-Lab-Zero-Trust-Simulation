# Methodology

## Testbed Architecture

The testbed emulates a small enterprise network using Linux network 
namespaces and virtual bridges, avoiding hypervisor-specific dependencies. 
Three isolated segments were provisioned:

| Segment | Subnet | Role |
|---|---|---|
| VLAN 10 | 10.10.10.0/24 | Admin / attacker node |
| VLAN 20 | 10.10.20.0/24 | Corporate endpoint |
| VLAN 30 | 10.10.30.0/24 | IoT / CCTV endpoint |

Each segment is backed by a Linux bridge (br-vlan10/20/30) acting as a 
Layer 2 switch. Endpoints are implemented as Linux network namespaces 
(ns-admin, ns-corp, ns-iot) connected to their respective bridge via 
veth (virtual ethernet) pairs, providing full network-stack isolation 
per segment without requiring separate virtual machines.

## Tooling

- **iproute2** (ip, bridge) — topology construction and interface management
- **nftables** — policy enforcement (Zero Trust default-deny firewall)
- **Bash** — automated, idempotent setup/teardown scripting for reproducibility

## Zero Trust Policy Design

Following NIST SP 800-207 principles, a default-deny policy was applied 
to the forward chain, with explicit allow-rules for only the minimum 
required traffic (e.g., SSH from the admin segment to the corporate 
segment). No implicit trust is granted based on network location alone.

## Implementation Challenges

Initial firewall validation showed no policy enforcement due to 
host-originated traffic bypassing the FORWARD chain; resolved by 
namespacing the admin endpoint (ns-admin) to ensure symmetric 
inter-segment traffic flow through the kernel's forwarding path — a 
subtle but critical distinction between locally-generated and routed 
traffic in Linux netfilter.

Earlier iterations attempted multi-VM topologies across VMware and 
VirtualBox hypervisors; this was abandoned after confirming that 
virtual switches are not shared across hypervisor platforms, and that 
namespace-based emulation offered equivalent segmentation fidelity 
with significantly lower resource overhead and higher reproducibility.
