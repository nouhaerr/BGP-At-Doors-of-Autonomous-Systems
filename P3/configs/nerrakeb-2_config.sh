#!/bin/bash
#
# Leaf Router Configuration - nerrakeb-2
# BADASS Project - Part 3
#
# This router is a VTEP (leaf) with:
# - BGP EVPN for MAC distribution
# - VXLAN for overlay network
# - OSPF for underlay
#

echo "=========================================="
echo "Configuring nerrakeb-2 (Leaf/VTEP)"
echo "=========================================="

# Configure interface to route reflector
echo "→ Configuring underlay interface..."
ip link set eth0 up
ip addr add 10.1.1.2/30 dev eth0

# Configure interface to host
echo "→ Configuring host interface..."
ip link set eth1 up

# Configure loopback (VTEP source)
echo "→ Configuring loopback..."
ip link add lo0 type dummy
ip addr add 1.1.1.2/32 dev lo0
ip link set lo0 up

# Enable IP forwarding
sysctl -w net.ipv4.ip_forward=1

# Create VXLAN interface (nolearning - EVPN will handle MACs)
echo "→ Creating VXLAN interface..."
ip link add vxlan10 type vxlan \
    id 10 \
    dstport 4789 \
    local 1.1.1.2 \
    nolearning

# Create bridge
echo "→ Creating bridge..."
ip link add br0 type bridge

# Add interfaces to bridge
ip link set vxlan10 master br0
ip link set eth1 master br0

# Bring everything up
ip link set vxlan10 up
ip link set br0 up

echo ""
echo "→ Entering FRR configuration..."
sleep 2

# Configure FRR
vtysh << 'VTYSH_EOF'
configure terminal

hostname nerrakeb-2

! Configure OSPF
router ospf
  network 10.1.1.0/30 area 0
  network 1.1.1.2/32 area 0
  exit

! Configure BGP
router bgp 1
  bgp router-id 1.1.1.2
  no bgp default ipv4-unicast
  
  ! Route reflector as neighbor
  neighbor 1.1.1.1 remote-as 1
  neighbor 1.1.1.1 update-source lo0
  
  ! EVPN address family
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
echo "Configuration Complete"
echo "=========================================="
echo ""
echo "VXLAN interface:"
ip -d link show vxlan10 | head -5
echo ""
echo "Bridge:"
bridge link show
echo ""
echo "OSPF neighbors:"
vtysh -c "show ip ospf neighbor"
echo ""
echo "BGP EVPN:"
vtysh -c "show bgp l2vpn evpn summary"
echo ""
