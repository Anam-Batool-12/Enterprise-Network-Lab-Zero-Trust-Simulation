# Troubleshooting Log

Documented issues encountered during lab implementation, following a 
Problem → Investigation → Root Cause → Fix → Verification structure.

---

## Case 1: Zero Trust firewall rules loaded but showed zero enforcement

**Problem:**
After applying nftables rules with a default-deny policy on the `forward` 
chain, ping tests from Kali to both VLAN20 and VLAN30 continued to 
succeed with 0% packet loss — identical to the pre-firewall baseline.

**Investigation:**
Ran `sudo nft list ruleset` and inspected the `zerotrust` table counters:

    log prefix "ZT-DROP: " counter packets 0 bytes 0 drop

The counter remained at zero across multiple ping attempts, indicating 
the rule was never being evaluated against the test traffic — the issue 
was not a misconfigured rule, but a traffic-path mismatch.

**Root Cause:**
Traffic originating directly from the Kali host (rather than from a 
namespaced device) is classified by the Linux kernel as `OUTPUT` traffic, 
not `FORWARD` traffic. The nftables policy was correctly written for the 
`forward` chain, but host-originated pings never entered that chain — 
they bypassed it entirely. This created a false impression that the 
firewall was non-functional.

**Fix:**
Created a dedicated network namespace (`ns-admin`) for the Kali/admin 
endpoint, matching the existing namespace pattern used for `ns-corp` and 
`ns-iot`. This ensured all inter-segment traffic — including from the 
admin segment — passed through the kernel's forwarding path symmetrically.

**Verification:**
    sudo ip netns exec ns-admin ping -c 3 10.10.20.50   # 100% packet loss
    sudo ip netns exec ns-admin ping -c 3 10.10.30.50   # 100% packet loss
    sudo nft list ruleset | grep ZT-DROP
    # counter packets 6 bytes 504 drop

**Lesson:**
Firewall rule validation must account for whether test traffic actually 
traverses the chain being tested. Locally-generated (OUTPUT) traffic and 
routed (FORWARD) traffic are distinct paths in Linux netfilter, and 
conflating them can produce misleading "the firewall isn't working" 
conclusions during testing.

---
