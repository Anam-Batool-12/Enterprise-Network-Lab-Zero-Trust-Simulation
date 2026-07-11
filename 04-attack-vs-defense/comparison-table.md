
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

## Nmap Reconnaissance — Attacker Perspective

| Target | Scan Type | Before Zero Trust | After Zero Trust |
|--------|-----------|--------------------|--------------------|
| VLAN20 | Default host discovery | Host up | **Host "seems down"** (ICMP not whitelisted) |
| VLAN20 | Forced scan (-Pn), 6 ports | 1 open (SSH), 5 closed | 1 open (SSH), 5 **filtered** |
| VLAN30 | Default host discovery | Host up | **Host "seems down"** |
| VLAN30 | Forced scan (-Pn), 6 ports | 6 closed (host visible) | **6 filtered** (host appears inaccessible) |

### Key finding: host discovery bypass
Standard Nmap host discovery (ICMP-based ping sweep) failed entirely 
against both Zero-Trust-protected segments, reporting hosts as "down" 
despite being fully operational. This is a stronger security outcome 
than port-level filtering alone: an attacker running a default network 
sweep would not even identify VLAN20 or VLAN30 hosts as scan targets, 
let alone enumerate their services. Only a forced, non-ping scan 
(-Pn) revealed the filtered port states shown above.

### Interpretation
"Closed" (before) tells an attacker a host exists and is reachable, 
just not listening on that port — useful reconnaissance. "Filtered" 
(after) provides no such confirmation: it is indistinguishable from 
a host that does not exist at all, significantly raising the cost 
and uncertainty of reconnaissance for an attacker.
