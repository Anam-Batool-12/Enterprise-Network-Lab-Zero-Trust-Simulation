# Platform Decision Log

Explored: VMware + Debian router, OPNsense on VirtualBox, cross-hypervisor 
multi-VM setup (VMware Kali + VirtualBox router).

All abandoned due to: driver conflicts, VT-x/I-O APIC issues, and 
confirmed incompatibility of virtual switches across hypervisors.

Final choice: Linux network namespaces on a single host (Kali VM), 
matching the architecture used by Docker and Mininet. Full reasoning 
and debugging trail in troubleshooting-log.md.
