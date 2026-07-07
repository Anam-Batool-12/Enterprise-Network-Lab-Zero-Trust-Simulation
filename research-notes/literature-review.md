# Literature Review

## 1. Zero Trust Architecture — Foundations and Surveys

**A Survey on Zero Trust Architecture: Challenges and Future Trends (2022)**
Traditional perimeter-based security is no longer sufficient for modern 
networks. This survey explains the core principles of Zero Trust 
Architecture, including identity verification, access control, and trust 
evaluation, while discussing its benefits, current challenges, and future 
research directions.
*Relevance:* Establishes the theoretical baseline (identity verification, 
access control) that this project operationalizes at the network layer 
via default-deny firewall policy.

**A Comprehensive Review and Comparative Analysis of Zero Trust 
Architecture (2025)**
This paper reviews different Zero Trust models and compares their 
implementation strategies across industries. It also identifies research 
gaps and provides practical guidance for organizations planning to adopt 
Zero Trust security.
*Relevance:* Highlights the gap between ZTA theory and industry 
implementation — this project contributes a concrete, reproducible 
implementation example at small-network scale.

**Zero Trust Architecture: A Systematic Literature Review (2025)**
The authors analyze ten years of Zero Trust research using a systematic 
review approach. The study summarizes major application areas, enabling 
technologies, implementation challenges, and shows how Zero Trust 
strengthens security in distributed environments.
*Relevance:* Confirms that most existing ZTA literature is 
survey/theoretical in nature — reinforcing the value of an 
experimental, testbed-based contribution.

## 2. Microsegmentation

**A Three-Tier Microsegmentation Framework for Enterprise Networks under 
Zero Trust Architecture (2026)**
This paper proposes a three-layer microsegmentation framework that 
improves enterprise network security through automated segmentation and 
endpoint protection. Experimental results show a significant reduction 
in attack paths while maintaining good performance and scalability.
*Relevance:* Directly parallels this project's three-segment design 
(admin/corporate/IoT); their attack-path-reduction metric is analogous 
to this project's before/after reachability comparison.

**A Taxonomy of Segmentation in Network Security**
The paper introduces a standardized classification of network 
segmentation techniques to improve consistency in security research and 
deployment. It also demonstrates how the proposed taxonomy can help 
analyze existing solutions and identify future research opportunities.
*Relevance:* Provides a classification framework to position this 
project's VLAN + nftables approach within the broader segmentation 
literature.

**The Pathway to Implementing Zero Trust: Why Microsegmentation Remains 
the Critical Barrier**
This study explains that the biggest challenge in adopting Zero Trust is 
implementing microsegmentation in complex enterprise environments. Using 
a real-world government case study, it highlights both technical and 
organizational obstacles that slow deployment.
*Relevance:* This project's own implementation friction (host vs. 
FORWARD-chain traffic, cross-hypervisor networking failures) is a 
small-scale, hands-on illustration of exactly the technical barriers 
this paper describes at enterprise scale.

## 3. SDN Testbeds and Network Emulation (Mininet)

**Mininet and Free Range Routing for Hybrid Software Defined Network 
Testing (2025)**
The authors extend Mininet by integrating Free Range Routing (FRRouting) 
to support realistic routing protocols like OSPF. This enhancement 
allows researchers to study routing behavior, convergence, and fault 
tolerance in hybrid SDN environments.
*Relevance:* Confirms namespace/bridge-based emulation (the same 
underlying technique used in this project) as an accepted method for 
realistic network research.

**Implementation of Fault-Resilient Network Slicing using GNS3-Mininet 
Hybrid Testbed**
This research presents an SDN-based network slicing solution that 
automatically reroutes traffic when failures occur. The hybrid 
GNS3-Mininet testbed validates the approach and demonstrates improved 
network reliability and service continuity.
*Relevance:* Further precedent for lightweight, software-based testbeds 
producing publishable experimental results without physical hardware.

**Is Mininet the Right Solution for an SDN Testbed?**
The paper evaluates Mininet as an SDN testing platform and identifies 
several limitations related to security, isolation, and VLAN 
configuration. It concludes that building a secure and realistic SDN 
testbed with Mininet requires considerable additional effort.
*Relevance — IMPORTANT:* This paper's documented limitations (VLAN 
configuration difficulty, isolation challenges) independently corroborate 
the implementation friction encountered in this project (e.g., the 
host-traffic vs. FORWARD-chain bug during firewall validation). This 
project's troubleshooting log serves as a practical, documented instance 
of the exact limitations this paper describes analytically.

## 4. Frameworks and Standards

**Security Evaluation Framework for Cloud ERP Systems using NIST and ISO 
Standards (2026)**
This study proposes a security assessment framework based on NIST CSF 
2.0 and ISO/IEC 27001 to evaluate cloud ERP systems. It provides 
measurable security scores and examines modern approaches such as Zero 
Trust integration and blockchain-based auditing.
*Relevance:* Demonstrates how Zero Trust is increasingly integrated into 
broader security scoring frameworks, contextualizing this project's 
network-layer focus within a larger governance picture.

**PURITY: An Industry-Standard-Based Security Framework for IT-OT 
Convergence**
The paper introduces a security framework that combines major industry 
standards to protect integrated IT and OT environments. It emphasizes 
layered security, network segmentation, risk assessment, and practical 
implementation for small and medium-sized enterprises.
*Relevance:* The IoT/CCTV segment in this project's topology mirrors the 
IT-OT convergence problem this paper addresses — both treat 
operational/embedded devices as a distinct, higher-risk segment 
requiring isolation.

## Research Gap Identified

The reviewed literature splits into two largely separate tracks: (1) 
Zero Trust survey and framework papers (1, 2, 3, 4, 6) that are 
predominantly theoretical, conceptual, or based on large-scale 
enterprise/government case studies, and (2) SDN testbed papers (7, 8, 9) 
that focus on routing and fault-tolerance rather than security policy 
enforcement. Notably, Paper 9 explicitly identifies VLAN configuration 
and isolation as unresolved weaknesses in Mininet-style testbeds.

This project addresses the space between these tracks: a low-cost, 
fully reproducible, script-based network namespace testbed that 
implements and empirically validates a Zero Trust default-deny policy, 
while transparently documenting the practical implementation barriers 
(e.g., traffic-path misclassification in Linux netfilter) that 
theoretical papers do not surface. It contributes a hands-on, 
reproducible case study bridging Zero Trust theory and SDN-style 
network emulation.
