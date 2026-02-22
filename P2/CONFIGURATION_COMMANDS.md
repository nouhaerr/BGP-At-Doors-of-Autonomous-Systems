# Part 2 Configuration Commands

## Quick Reference

### Static VXLAN Setup

**On routeur_kkouaz-1:**
```bash
# Underlay network
ip link set eth0 up
ip addr add 10.1.1.1/24 dev eth0
ip link set eth1 up

# VXLAN (static remote)
ip link add vxlan10 type vxlan \
    id 10 \
    dstport 4789 \
    local 10.1.1.1 \
    remote 10.1.1.2

# Bridge
ip link add br0 type bridge
ip link set vxlan10 master br0
ip link set eth1 master br0
ip link set vxlan10 up
ip link set br0 up
```

**On routeur_kkouaz-2:**
```bash
# Underlay network
ip link set eth0 up
ip addr add 10.1.1.2/24 dev eth0
ip link set eth1 up

# VXLAN (static remote)
ip link add vxlan10 type vxlan \
    id 10 \
    dstport 4789 \
    local 10.1.1.2 \
    remote 10.1.1.1

# Bridge
ip link add br0 type bridge
ip link set vxlan10 master br0
ip link set eth1 master br0
ip link set vxlan10 up
ip link set br0 up
```

**On host_kkouaz-1:**
```bash
ip addr add 20.1.1.1/24 dev eth0
ip link set eth0 up
ping 20.1.1.2
```

**On host_kkouaz-2:**
```bash
ip addr add 20.1.1.2/24 dev eth0
ip link set eth0 up
ping 20.1.1.1
```

---

### Multicast VXLAN Setup

**On routeur_kkouaz-1:**
```bash
# Underlay network
ip link set eth0 up
ip addr add 10.1.1.1/24 dev eth0
ip link set eth1 up

# VXLAN (multicast)
ip link add vxlan10 type vxlan \
    id 10 \
    dstport 4789 \
    local 10.1.1.1 \
    group 239.1.1.1 \
    dev eth0

# Bridge
ip link add br0 type bridge
ip link set vxlan10 master br0
ip link set eth1 master br0
ip link set vxlan10 up
ip link set br0 up
```

**On routeur_kkouaz-2:**
```bash
# Underlay network
ip link set eth0 up
ip addr add 10.1.1.2/24 dev eth0
ip link set eth1 up

# VXLAN (multicast - same group!)
ip link add vxlan10 type vxlan \
    id 10 \
    dstport 4789 \
    local 10.1.1.2 \
    group 239.1.1.1 \
    dev eth0

# Bridge
ip link add br0 type bridge
ip link set vxlan10 master br0
ip link set eth1 master br0
ip link set vxlan10 up
ip link set br0 up
```

**Hosts:** Same as static VXLAN

---

## Verification Commands

### Check VXLAN Interface
```bash
ip -d link show vxlan10
```

### Check Bridge
```bash
bridge link show
ip link show br0
```

### Check MAC Learning
```bash
bridge fdb show dev vxlan10
bridge fdb show br br0
```

### Check Multicast Group
```bash
ip maddr show dev eth0
```

### Test Connectivity
```bash
# From hosts
ping 20.1.1.1
ping 20.1.1.2

# From routers (underlay)
ping 10.1.1.1
ping 10.1.1.2
```

### Capture VXLAN Traffic
```bash
# On router, capture on eth0 (underlay)
tcpdump -i eth0 -n udp port 4789 -v
```

---

## Key Differences

### Static vs Multicast

| Feature | Static VXLAN | Multicast VXLAN |
|---------|--------------|-----------------|
| Remote VTEP | Manual (`remote 10.1.1.2`) | Auto discovery (`group 239.1.1.1`) |
| Scalability | Poor (manual config) | Better (auto discovery) |
| BUM Traffic | Unicast to remote | Multicast to group |
| Use Case | 2-3 VTEPs | Many VTEPs |

**BUM** = Broadcast, Unknown unicast, Multicast

---

## Troubleshooting

**No connectivity between hosts:**
```bash
# Check bridge
bridge link show

# Check VXLAN
ip -d link show vxlan10

# Check underlay
ping <remote_router_ip>

# Check MAC table
bridge fdb show
```

**VXLAN not working:**
```bash
# Recreate VXLAN
ip link delete vxlan10
ip link delete br0
# Then reconfigure

# Check if interface is up
ip link show vxlan10
ip link show br0
```
