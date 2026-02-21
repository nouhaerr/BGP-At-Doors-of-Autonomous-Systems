# Part 3: BGP EVPN

## Quick Start
```bash
cd badass-project/P3
bash run-all.sh
```

## Topology
```
          wil-1 (Route Reflector)
         /  |  \
        /   |   \
    wil-2 wil-3 wil-4 (Leaf VTEPs)
      |     |     |
   host1  host2  host3
```

## What Happens

1. **OSPF** creates underlay routing
2. **BGP** sessions establish to route reflector
3. **EVPN** distributes MAC addresses automatically
4. **VXLAN** tunnels created dynamically
5. **Hosts** can all ping each other!

## Network Details

### Loopbacks (VTEP addresses)
- wil-1: 1.1.1.1/32
- wil-2: 1.1.1.2/32
- wil-3: 1.1.1.3/32
- wil-4: 1.1.1.4/32

### Underlay (router-to-router)
- wil-1 ↔ wil-2: 10.1.1.0/30
- wil-1 ↔ wil-3: 10.1.1.4/30
- wil-1 ↔ wil-4: 10.1.1.8/30

### Overlay (hosts)
- host_wil-1: 20.1.1.1/24
- host_wil-2: 20.1.1.2/24
- host_wil-3: 20.1.1.3/24

### Protocols
- BGP AS: 1
- OSPF Area: 0
- VNI: 10

## Verification

### Check BGP
```bash
vtysh -c "show bgp l2vpn evpn summary"
```

### Check EVPN Routes
```bash
vtysh -c "show bgp l2vpn evpn route"
```

### Check VXLAN
```bash
ip -d link show vxlan10
bridge fdb show
```

### Check MAC Learning
```bash
vtysh -c "show evpn mac vni 10"
```

## Files

- `run-all.sh` - One script for everything
- `configs/` - Individual device configs
- `README.md` - This file
