
## Zero Trust Enforcement — Verified Results

| Path | Protocol | Before (Flat) | After (Zero Trust) |
|------|----------|----------------|----------------------|
| VLAN10 -> VLAN20 | ICMP (ping) | SUCCESS | BLOCKED |
| VLAN10 -> VLAN30 | ICMP (ping) | SUCCESS | BLOCKED |
| VLAN10 -> VLAN20 | TCP/22 (SSH) | N/A | ALLOWED (explicit policy) |

Root cause note: initial validation showed 0 dropped packets because 
host-originated (Kali-native) traffic bypasses the netfilter FORWARD 
chain entirely. Namespacing the admin endpoint (ns-admin) corrected 
this, confirming policy enforcement with ZT-DROP counters incrementing 
as expected (6 packets dropped across 2 blocked ping tests).

## Zero Trust Enforcement — Verified Results

| Path | Protocol | Before (Flat) | After (Zero Trust) |
|------|----------|----------------|----------------------|
| VLAN10 -> VLAN20 | ICMP (ping) | SUCCESS | BLOCKED |
| VLAN10 -> VLAN30 | ICMP (ping) | SUCCESS | BLOCKED |
| VLAN10 -> VLAN20 | TCP/22 (SSH) | N/A | ALLOWED (explicit policy) |

Root cause note: initial validation showed 0 dropped packets because 
host-originated (Kali-native) traffic bypasses the netfilter FORWARD 
chain entirely. Namespacing the admin endpoint (ns-admin) corrected 
this, confirming policy enforcement with ZT-DROP counters incrementing 
as expected (6 packets dropped across 2 blocked ping tests).
