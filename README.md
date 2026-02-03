# BADASS - BGP At Doors of Autonomous Systems is Simple

## 📚 Educational Guide to BGP, VXLAN, and EVPN

This comprehensive guide accompanies the BADASS network administration project, designed to help you understand and implement modern data center networking technologies.

---

## 🎯 Project Overview

This project introduces you to enterprise-grade networking concepts through hands-on implementation:

- **Part 1**: GNS3 and Docker configuration
- **Part 2**: VXLAN overlay networks
- **Part 3**: BGP EVPN for MAC learning and distribution

By the end, you'll have built a simulated data center network with automatic MAC address learning and dynamic routing.

---

## 🧠 Core Concepts Explained

### What is BGP?

**Border Gateway Protocol (BGP)** is the routing protocol that powers the Internet. Think of it as the postal service of the internet:

- **Autonomous Systems (AS)**: Like different countries with their own postal systems
- **BGP Routers**: Like international postal hubs that exchange routing information
- **Routes**: Like knowing which path a package should take to reach its destination

**Key characteristics:**
- Path-vector protocol (not just distance-based)
- Highly scalable (handles millions of routes)
- Policy-based routing (you control which routes to accept/advertise)

### What is MP-BGP?

**Multi-Protocol BGP** extends BGP beyond just IPv4 routing:

- Can carry routes for IPv6, VPNs, and EVPN
- Uses **Address Families** to distinguish different types of routing information
- Think of it as BGP learning multiple languages instead of just one

### What is VXLAN?

**Virtual Extensible LAN** creates overlay networks over existing IP infrastructure:

```
Traditional VLAN: Limited to ~4096 VLANs
VXLAN: Supports 16 million virtual networks (VNIs)
```

**How it works:**
1. Original Ethernet frame is encapsulated in UDP packet
2. Packet travels over existing IP network (underlay)
3. Destination decapsulates and delivers original frame

**Use cases:**
- Multi-tenant data centers
- Network segmentation at massive scale
- Extending layer 2 networks across layer 3 boundaries

**VTEP (VXLAN Tunnel Endpoint)**: The device that encapsulates/decapsulates VXLAN traffic

### What is EVPN?

**Ethernet VPN** is a BGP-based control plane for overlay networks:

**Without EVPN (Traditional):**
- Manual configuration or flooding for MAC learning
- Limited scalability
- No automatic failover

**With EVPN:**
- BGP distributes MAC addresses automatically
- Reduced flooding (more efficient)
- Built-in multi-homing support
- Works across data centers

**Route Types in EVPN:**
- **Type 2**: MAC/IP advertisement routes (actual host information)
- **Type 3**: Inclusive multicast routes (for flood traffic)
- **Type 5**: IP prefix routes (for routing between VXLANs)

### Route Reflector Concept

In large BGP networks, requiring every router to connect to every other router (full mesh) becomes unmanageable:

```
Without RR: N routers need N(N-1)/2 connections
With RR: N routers need N connections to RR
```

**Route Reflector (RR)** acts as a central hub:
- Clients connect only to the RR
- RR redistributes routes between clients
- Dramatically simplifies network topology

---

## 🛠️ Part 1: GNS3 and Docker Setup

### Objectives

1. Install and configure GNS3 network simulator
2. Create two custom Docker images
3. Integrate Docker containers with GNS3
4. Build a simple two-node topology

### Docker Image Requirements

**Image 1 - Basic Host:**
```dockerfile
# Minimal image for end hosts
- Base: Alpine Linux (lightweight)
- Tools: busybox (basic networking utilities)
- Purpose: Simulate client machines
```

**Image 2 - Network Router:**
```dockerfile
# Full-featured routing image
- Routing software: FRRouting (fork of Quagga)
- Services needed:
  * zebra: Manages routing table
  * bgpd: BGP routing daemon
  * ospfd: OSPF routing daemon
  * isisd: IS-IS routing protocol
- Tools: busybox for troubleshooting
```

### Key Concepts

**FRRouting (FRR)**: Open-source routing software suite
- Supports BGP, OSPF, IS-IS, and more
- Industry-standard for Linux routing
- Command-line interface similar to Cisco IOS

**Why multiple routing protocols?**
- **OSPF**: For internal network routing (underlay)
- **BGP**: For overlay network control plane (EVPN)
- **IS-IS**: Alternative to OSPF (requirement for completeness)

### Setup Tips

1. **Docker image naming**: Include your login to make equipment identifiable
2. **No default IPs**: Keep images generic for reuse
3. **GNS3 integration**: Ensure images appear in GNS3 device list
4. **Testing**: Verify you can console into both container types

### Deliverables

```
P1/
├── P1.gns3project        # Exported GNS3 project (ZIP)
├── _yourlogin-1_host     # Configuration for host image
├── _yourlogin-2          # Configuration for router image
└── README.txt            # Setup documentation
```

---

## 🌐 Part 2: VXLAN Implementation

### Objectives

1. Create a VXLAN overlay network
2. Configure static VXLAN tunnels
3. Implement dynamic multicast VXLAN
4. Verify MAC address learning

### Network Topology

```
[Host1] --- [Switch/Router1] ~~~~~~~~ [Switch/Router2] --- [Host2]
              (VTEP)          VXLAN      (VTEP)
                              Tunnel
```

### Configuration Steps Explained

**Step 1: Create VXLAN Interface**
```bash
# Create VXLAN interface with VNI 10
ip link add vxlan10 type vxlan id 10 \
  dstport 4789 \
  local <local-vtep-ip> \
  remote <remote-vtep-ip>
```

**Parameters explained:**
- `id 10`: VXLAN Network Identifier (VNI) - like a VLAN ID
- `dstport 4789`: Standard VXLAN UDP port
- `local`: This VTEP's IP address (underlay)
- `remote`: Other VTEP's IP address (for static config)

**Step 2: Create Bridge**
```bash
# Create bridge to connect VXLAN and physical interfaces
ip link add br0 type bridge
ip link set vxlan10 master br0
ip link set eth1 master br0
```

**Why a bridge?**
- Connects the VXLAN tunnel to local hosts
- Handles MAC learning at layer 2
- Like a virtual switch

**Step 3: Dynamic Multicast Configuration**
```bash
# Use multicast instead of static remote
ip link add vxlan10 type vxlan id 10 \
  dstport 4789 \
  local <local-vtep-ip> \
  group 239.1.1.1 \
  dev eth0
```

**Multicast benefits:**
- No need to specify every remote VTEP
- Automatic neighbor discovery
- Better for multiple VTEPs

### Verification Commands

```bash
# Show VXLAN interface details
ip -d link show vxlan10

# Display MAC address table
bridge fdb show dev vxlan10

# Verify bridge configuration
bridge link show

# Capture and analyze VXLAN traffic
tcpdump -i eth0 -n port 4789
```

### What to Look For

In packet captures, you should see:
- **Outer IP header**: Underlay network routing
- **UDP header**: Port 4789
- **VXLAN header**: VNI = 10
- **Inner Ethernet frame**: Original packet from host

### Deliverables

```
P2/
├── P2.gns3project          # Exported GNS3 project (ZIP)
├── _yourlogin-1_host       # Host 1 configuration
├── _yourlogin-1_switch     # VTEP 1 configuration
├── _yourlogin-2_host       # Host 2 configuration
└── _yourlogin-2_switch     # VTEP 2 configuration
```

---

## 🚀 Part 3: BGP EVPN Data Center

### Objectives

1. Build a multi-VTEP topology with route reflector
2. Configure BGP EVPN for automatic MAC learning
3. Implement OSPF for underlay routing
4. Verify dynamic MAC distribution

### Network Architecture

```
                    [Route Reflector]
                     (RR_yourlogin)
                           |
            +-------------+-------------+
            |             |             |
         [VTEP1]       [VTEP2]       [VTEP3]
            |             |             |
         [Host1]       [Host2]       [Host3]
```

**Design principles:**
- **Underlay network**: OSPF provides IP connectivity between VTEPs
- **Overlay network**: BGP EVPN distributes MAC/IP information
- **Route reflector**: Simplifies BGP topology (no full mesh needed)

### Layer by Layer Configuration

#### Layer 1: Underlay (OSPF)

**Purpose**: Provide IP connectivity between all VTEPs and RR

```bash
# FRRouting configuration
router ospf
  network 1.1.1.0/24 area 0
  network 10.1.1.0/24 area 0
```

**Why OSPF?**
- Fast convergence
- Automatic route discovery
- Standard in data center underlay networks

#### Layer 2: VXLAN Data Plane

```bash
# Create VXLAN interface (no remote needed with EVPN)
ip link add vxlan10 type vxlan \
  id 10 \
  dstport 4789 \
  local 1.1.1.X \
  nolearning

# Bridge configuration
ip link add br0 type bridge
ip link set vxlan10 master br0
ip link set eth1 master br0
```

**Note**: `nolearning` flag because BGP EVPN handles MAC learning

#### Layer 3: BGP EVPN Control Plane

**On Route Reflector:**
```bash
router bgp 1
  neighbor 1.1.1.1 remote-as 1
  neighbor 1.1.1.2 remote-as 1
  neighbor 1.1.1.3 remote-as 1
  
  address-family l2vpn evpn
    neighbor 1.1.1.1 activate
    neighbor 1.1.1.1 route-reflector-client
    neighbor 1.1.1.2 activate
    neighbor 1.1.1.2 route-reflector-client
    neighbor 1.1.1.3 activate
    neighbor 1.1.1.3 route-reflector-client
  exit-address-family
```

**On each VTEP:**
```bash
router bgp 1
  neighbor 1.1.1.254 remote-as 1
  
  address-family l2vpn evpn
    neighbor 1.1.1.254 activate
    advertise-all-vni
  exit-address-family
```

### Understanding EVPN Route Types

**Type 3 Routes (IMET - Inclusive Multicast Ethernet Tag):**
- Advertised by each VTEP when it comes online
- Tells other VTEPs: "I exist and participate in VNI 10"
- Used for BUM traffic (Broadcast, Unknown unicast, Multicast)

**Type 2 Routes (MAC/IP Advertisement):**
- Created when a host becomes active
- Contains: MAC address, IP address (optional), VNI, VTEP IP
- Allows other VTEPs to learn remote MACs without flooding

### The Magic of EVPN

**Traditional VXLAN problem:**
```
Host1 wants to talk to Host2
→ VTEP1 doesn't know where Host2's MAC is
→ Floods packet to all VTEPs
→ Inefficient at scale
```

**With BGP EVPN:**
```
Host2 connects to VTEP2
→ VTEP2 learns MAC locally
→ VTEP2 sends BGP Type 2 route to RR
→ RR redistributes to all VTEPs
→ VTEP1 now knows Host2's MAC is behind VTEP2
→ Direct unicast traffic (no flooding)
```

### Verification and Testing

**Check BGP EVPN neighbors:**
```bash
show bgp l2vpn evpn summary
```

**View EVPN routes:**
```bash
show bgp l2vpn evpn route
```

**Verify MAC addresses learned via BGP:**
```bash
show evpn mac vni 10
```

**Test connectivity:**
```bash
# From Host1, ping Host2
ping <host2-ip>

# Capture to see VXLAN encapsulation
tcpdump -i eth0 -n -v port 4789
```

### What Success Looks Like

1. **OSPF converged**: All VTEPs can ping each other's loopbacks
2. **BGP sessions established**: All VTEPs peer with RR
3. **Type 3 routes present**: One per VTEP for VNI 10
4. **Type 2 routes appear**: When hosts become active
5. **Ping works**: Hosts can communicate across VTEPs
6. **No ARP flooding**: MAC addresses learned via BGP, not flooding

### Deliverables

```
P3/
├── P3.gns3project          # Exported GNS3 project (ZIP)
├── _yourlogin-RR           # Route reflector config
├── _yourlogin-1            # VTEP 1 config
├── _yourlogin-1_host       # Host 1 config
├── _yourlogin-2            # VTEP 2 config
├── _yourlogin-2_host       # Host 2 config
├── _yourlogin-3            # VTEP 3 config
└── _yourlogin-3_host       # Host 3 config
```

---

## 📖 Key Terms Glossary

| Term | Definition |
|------|------------|
| **AS (Autonomous System)** | A collection of IP networks under single administrative control |
| **BGP** | Border Gateway Protocol - the routing protocol of the Internet |
| **BUM Traffic** | Broadcast, Unknown unicast, and Multicast traffic |
| **EVPN** | Ethernet VPN - BGP-based control plane for overlay networks |
| **FRR** | Free Range Routing - open-source routing software |
| **MP-BGP** | Multi-Protocol BGP - extension supporting multiple address families |
| **NLRI** | Network Layer Reachability Information - routing update data |
| **OSPF** | Open Shortest Path First - interior routing protocol |
| **RR** | Route Reflector - BGP router that redistributes routes to clients |
| **Underlay** | Physical network providing basic IP connectivity |
| **Overlay** | Virtual network built on top of underlay (e.g., VXLAN) |
| **VNI** | VXLAN Network Identifier - like a VLAN ID for VXLAN (24-bit) |
| **VTEP** | VXLAN Tunnel Endpoint - device that encapsulates/decapsulates VXLAN |
| **VXLAN** | Virtual Extensible LAN - overlay network technology |

---

## 🎓 Learning Resources

### Official Documentation
- **RFC 4271**: BGP-4 Protocol
- **RFC 4760**: Multiprotocol Extensions for BGP (MP-BGP)
- **RFC 7348**: VXLAN
- **RFC 7432**: BGP MPLS-Based Ethernet VPN (EVPN)

### Recommended Reading
1. **BGP Fundamentals**: Understand path selection, attributes, and policies
2. **VXLAN Deep Dive**: Learn encapsulation format and packet flow
3. **EVPN Architecture**: Study control plane vs data plane separation
4. **FRRouting Documentation**: Configuration syntax and commands

### Practical Tips
- **Start simple**: Get Part 1 working before moving to Part 2
- **Incremental testing**: Verify each step (OSPF, then BGP, then EVPN)
- **Packet captures**: Use tcpdump to understand traffic flows
- **Logs are your friend**: Check FRR logs for troubleshooting
- **Draw diagrams**: Visualize underlay vs overlay networks

---

## 🐛 Common Troubleshooting

### BGP Sessions Won't Establish
```bash
# Check:
1. IP connectivity (can VTEPs ping each other?)
2. Firewall rules (TCP port 179 for BGP)
3. BGP configuration (correct AS numbers, neighbor IPs?)
4. FRR service running (systemctl status frr)
```

### VXLAN Not Working
```bash
# Verify:
1. VXLAN interface created (ip link show)
2. Correct VNI configured on all sides
3. UDP port 4789 not blocked
4. Bridge configuration correct
5. Underlay network functional
```

### No Type 2 Routes
```bash
# Check:
1. Host actually connected and active
2. "advertise-all-vni" configured in BGP
3. Bridge learning not interfering (use nolearning)
4. BGP EVPN address family activated
```

### MAC Addresses Not Learning
```bash
# Investigate:
1. BGP EVPN sessions established
2. VXLAN interface in bridge
3. No MAC filtering enabled
4. Route reflector properly configured
```

---

## ✅ Pre-Submission Checklist

- [ ] All three parts completed (P1, P2, P3)
- [ ] Folders at repository root with correct names
- [ ] GNS3 projects exported as ZIP files
- [ ] Configuration files include detailed comments
- [ ] Equipment named with your login
- [ ] ZIP archives include base Docker images
- [ ] All files visible in git repository
- [ ] Can successfully import and run projects
- [ ] Understand all networking concepts used
- [ ] Can explain BGP, VXLAN, EVPN, and their interaction

---

## 🎯 Evaluation Preparation

Be ready to explain:

1. **BGP fundamentals**: Why BGP? How does it differ from OSPF?
2. **VXLAN encapsulation**: Show the packet structure
3. **EVPN route types**: What is Type 2 vs Type 3?
4. **Route reflector role**: Why use RR instead of full mesh?
5. **Underlay vs overlay**: How do they work together?
6. **MAC learning process**: How does a MAC appear in the network?
7. **Traffic flow**: Trace a packet from Host1 to Host3

### Demo Scenarios

Practice these:
- Bring up a new host and show Type 2 route creation
- Take down a VTEP and show route withdrawal
- Explain packet capture showing VXLAN encapsulation
- Show MAC address table and correlate with BGP routes

---

## 🌟 Advanced Concepts (Beyond Scope)

If you want to go further:

- **VXLAN Routing**: Layer 3 forwarding between VXLANs (Type 5 routes)
- **Multi-tenancy**: Using different VNIs for isolated networks
- **Anycast gateway**: Same gateway IP on multiple VTEPs
- **ESI (Ethernet Segment Identifier)**: Multi-homing support
- **BFD**: Fast failure detection for BGP sessions

---

## 📝 Final Notes

This project simulates real-world data center networking:

- **Cloud providers** use these technologies for multi-tenant isolation
- **Enterprises** deploy EVPN in modern data centers
- **Skills gained** are directly applicable to production networks

The complexity is intentional—BGP EVPN represents modern networking. Take your time, understand each layer, and build incrementally. When something doesn't work, systematic troubleshooting is key.

Good luck, and enjoy building your virtual data center! 🚀

---

**Project Version**: 2.1  
**Document Type**: Network Administration  
**Difficulty**: Advanced  
**Prerequisites**: NetPractice or equivalent networking knowledge
