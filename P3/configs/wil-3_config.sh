#!/bin/bash
#
# Leaf Router Configuration - wil-3
# BADASS Project - Part 3
#

echo "=========================================="
echo "Configuring wil-3 (Leaf/VTEP)"
echo "=========================================="

# Configure interface to route reflector
ip link set eth0 up
ip addr add 10.1.1.6/30 dev eth0

# Configure interface to host
ip link set eth1 up

# Configure loopback
ip link add lo0 type dummy
ip addr add 1.1.1.3/32 dev lo0
ip link set lo0 up

# Enable IP forwarding
sysctl -w net.ipv4.ip_forward=1

# Create VXLAN interface
ip link add vxlan10 type vxlan \
    id 10 \
    dstport 4789 \
    local 1.1.1.3 \
    nolearning

# Create bridge
ip link add br0 type bridge
ip link set vxlan10 master br0
ip link set eth1 master br0
ip link set vxlan10 up
ip link set br0 up

echo ""
echo "→ Entering FRR configuration..."
sleep 2

# Configure FRR
vtysh << 'VTYSH_EOF'
configure terminal

hostname wil-3

router ospf
  network 10.1.1.4/30 area 0
  network 1.1.1.3/32 area 0
  exit

router bgp 1
  bgp router-id 1.1.1.3
  no bgp default ipv4-unicast
  neighbor 1.1.1.1 remote-as 1
  neighbor 1.1.1.1 update-source lo0
  address-family l2vpn evpn
    neighbor 1.1.1.1 activate
    advertise-all-vni
    exit-address-family
  exit

write memory
exit
VTYSH_EOF

echo ""
echo "=========================================="
echo "wil-3 Configured"
echo "=========================================="
echo ""
vtysh -c "show bgp l2vpn evpn summary"
echo ""
