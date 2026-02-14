# Part 1: GNS3 Configuration with Docker

## Quick Start

### For Team Members
```bash
# 1. Clone repository
git clone <your-repo-url>
cd badass-project

# 2. Build Docker images
bash build_all.sh

# 3. Setup Part 1
cd P1
bash setup.sh

# 4. Follow the on-screen GNS3 configuration instructions
```

## What's Included

### Docker Images

**host-alpine:1.0** (~45 MB)
- Base: Alpine Linux
- Tools: bash, busybox, network utilities
- Purpose: End host device

**router-frr:1.0** (~113 MB)
- Base: Alpine Linux
- Routing: FRRouting (BGP, OSPF, IS-IS)
- Purpose: Network router

### Configuration Scripts

Located in `configs/`:

**host_config.sh**
- Configures eth0: 10.1.1.1/30
- Sets default gateway: 10.1.1.2
- Tests connectivity

**router_config.sh**
- Configures eth0: 10.1.1.2/30
- Enables IP forwarding
- Configures FRRouting
- Tests connectivity

## Network Topology
```
┌─────────────────┐         ┌─────────────────┐
│  host_login-1   │         │  routeur_login  │
│                 │─────────│                 │
│  10.1.1.1/30    │   eth0  │  10.1.1.2/30    │
└─────────────────┘         └─────────────────┘
```

## Manual Configuration (in GNS3)

### On Host Console
```bash
# Create config script
cat > /config.sh << 'SCRIPT'
#!/bin/bash
ip addr add 10.1.1.1/30 dev eth0
ip link set eth0 up
ip route add default via 10.1.1.2
SCRIPT

chmod +x /config.sh
/config.sh

# Test
ping 10.1.1.2
```

### On Router Console
```bash
# Configure interface
ip addr add 10.1.1.2/30 dev eth0
ip link set eth0 up

# Configure FRR
vtysh
configure terminal
hostname routeur_yourlogin
interface eth0
  description Link to host
  ip address 10.1.1.2/30
  no shutdown
  exit
write memory
exit

# Test
ping 10.1.1.1
```

## Verification

### Check Host
```bash
ip addr show eth0
ip route show
ping 10.1.1.2
```

### Check Router
```bash
ip addr show eth0
sysctl net.ipv4.ip_forward
vtysh -c "show ip route"
vtysh -c "show running-config"
ping 10.1.1.1
```

## Troubleshooting

### Images not building
```bash
# Check Docker is running
sudo systemctl status docker

# Check user in docker group
groups | grep docker

# Rebuild
bash build_all.sh
```

### Can't connect in GNS3
```bash
# Check interface is up
ip link show eth0

# Check IP address
ip addr show eth0

# Reconfigure
ip addr flush dev eth0
# Run config script again
```

### FRR not running
```bash
# Check processes
ps aux | grep frr

# Restart FRR
/usr/lib/frr/frrinit.sh restart

# Check logs
tail -f /var/log/frr/frr.log
```

## Files Structure
```
P1/
├── configs/
│   ├── host_config.sh       # Host configuration
│   └── router_config.sh     # Router configuration
├── setup.sh                 # Setup helper
├── README.md               # This file
└── P1.gns3project          # Exported GNS3 project (after export)
```

## Export Project

In GNS3:
1. Stop all devices
2. File → Export portable project
3. Check "Include base images"
4. Save as: P1/P1.gns3project

## Team Workflow

1. **First person**: Set up and configure
2. **Export**: Create P1.gns3project
3. **Commit**: Push to repository
4. **Team members**: 
   - Pull repository
   - Build images: `bash build_all.sh`
   - Import project in GNS3

## Next Steps

After completing Part 1:
- Part 2: VXLAN configuration
- Part 3: BGP EVPN

