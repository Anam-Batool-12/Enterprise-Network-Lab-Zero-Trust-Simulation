## Flat Network Baseline — Connectivity Test

Date: $(date)

- Kali (VLAN10, 10.10.10.50) -> ns-corp (VLAN20, 10.10.20.50): SUCCESS, 0% packet loss
- Kali (VLAN10, 10.10.10.50) -> ns-iot (VLAN30, 10.10.30.50): SUCCESS, 0% packet loss

Conclusion: With no segmentation controls in place, unrestricted lateral 
movement is possible between all network segments — the admin/attacker 
segment can freely reach both corporate and IoT/CCTV segments.
