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

## Case 2: Firewall rule referenced veth port name instead of bridge device

**Problem:**
After fixing Case 1 (ns-admin namespace), the default-deny policy worked 
correctly for blocked traffic, but the explicit SSH allow-rule 
(VLAN10 -> VLAN20) still failed with "Connection timed out" — the 
traffic that should have been permitted was also being dropped.

**Investigation:**
Checked `dmesg | grep ZT-DROP` and confirmed matching SYN packets 
(destination port 22) were being logged and dropped, despite an 
apparently matching accept rule:

    iifname "veth-kali" oifname "veth-corp-br" tcp dport 22 accept

**Root Cause:**
The rule referenced `veth-kali`, a veth endpoint that only exists 
inside the ns-admin namespace's interface list — it is not visible 
from the root namespace where nftables evaluates the forward chain. 
When routing between two subnets via their bridges, the kernel's 
forwarding hook sees the bridge devices (`br-vlan10`, `br-vlan20`), 
not the individual veth ports attached to them.

**Fix:**
Rewrote the rule to reference the bridge devices instead of veth ports:

    iifname "br-vlan10" oifname "br-vlan20" tcp dport 22 accept

**Verification:**
    sudo nft list table inet zerotrust   # confirmed correct rule loaded
    (SSH connection still timed out at this stage — see Case 4)

**Lesson:**
When writing nftables/iptables rules for bridged, namespaced network 
topologies, rules on the forward hook must reference the bridge 
device (the Layer 2 switch), not veth port names that are only 
meaningful within a specific namespace's interface table.

---

## Case 3: Suspected rp_filter reverse-path drop (ruled out, documented for completeness)

**Problem:**
While diagnosing Case 4, `rp_filter` (reverse path filtering) was 
suspected as a possible cause of silent packet loss, since bridge 
interfaces showed `rp_filter = 2` (loose mode) by default.

**Investigation:**
    sysctl net.ipv4.conf.br-vlan10.rp_filter   # returned 2
    sysctl net.ipv4.conf.br-vlan20.rp_filter   # returned 2

**Action Taken:**
Disabled rp_filter across all interfaces (bridges and veth ports) as a 
precaution:

    for iface in $(ls /proc/sys/net/ipv4/conf/); do
        sysctl -w net.ipv4.conf.$iface.rp_filter=0
    done

**Verification:**
Traffic was still blocked after this change — rp_filter was not the 
root cause in this case (see Case 4 for the actual cause).

**Lesson:**
Reverse-path filtering is a valid and common cause of silent, 
unlogged packet drops in bridged/routed Linux topologies, and should 
always be checked early during connectivity debugging. However, ruling 
a hypothesis out is as valuable as confirming one — this elimination 
narrowed the investigation and directly led to discovering the actual 
cause (a second, independent firewall table) in Case 4.

---

## Case 4: A second, independently-registered firewall table silently dropped traffic

**Problem:**
Despite a correctly configured and verified-loaded accept rule 
(`iifname "br-vlan10" oifname "br-vlan20" tcp dport 22 accept`), SSH 
connections continued to fail with "Connection timed out." Critically, 
the custom table's ZT-DROP log counter remained at 0 throughout 
testing — the traffic was being dropped by something other than the 
zerotrust table.

**Investigation:**
Ran `sudo nft list ruleset` (the full ruleset, not just the custom 
table) and found a second table, managed by UFW via iptables-nft:

    table ip filter {
        chain FORWARD {
            type filter hook forward priority filter; policy drop;
            ...
            jump ufw-user-forward
        }
    }

The ufw-user-forward chain was empty, meaning all forwarded traffic 
fell through to UFW's own default-drop policy — independently of the 
custom zerotrust table.

**Root Cause:**
Linux's netfilter framework allows multiple independent tables to 
register at the same hook (in this case, forward). UFW's table and 
the custom zerotrust table were both attached to the forward hook 
simultaneously. Traffic had to pass both tables to be forwarded; the 
custom table's accept rule correctly permitted the traffic, but UFW's 
separate, empty forward chain dropped it independently, before it 
could be logged as a ZT-DROP event.

**Fix:**
    sudo ufw disable

**Verification:**
    sudo ip netns exec ns-admin ssh root@10.10.20.50
    # Successful login, confirming the allow-rule now takes effect

**Lesson:**
The absence of drop-counter activity in a custom firewall table does 
NOT prove that table is not responsible for observed packet loss — 
multiple firewall tables can coexist at the same netfilter hook, each 
capable of independently dropping traffic. Diagnosing this required 
inspecting the complete ruleset (nft list ruleset) across all 
registered tables, not just the table under active development. This 
is a significant, generalizable finding for anyone deploying custom 
nftables policies on systems with a pre-existing firewall manager 
(UFW, firewalld) already active.
