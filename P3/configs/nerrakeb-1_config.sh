#!/bin/bash
#
# Route Reflector Configuration - nerrakeb-1
# BADASS Project - Part 3
#
# This router is the BGP Route Reflector
# - Connects to all leaf routers
# - Reflects BGP EVPN routes between them
# - Runs OSPF for underlay
#

echo "=========================================="
echo "Configuring nerrakeb-1 (Route Reflector)"
echo "=========================================="

# Configure interfaces
echo "→ Configuring interfaces..."
ip link set eth0 up
ip addr add 10.1.1.1/30 dev eth0   # Link to nerrakeb-2

ip link set eth1 up
ip addr add 10.1.1.5/30 dev eth1   # Link to nerrakeb-3

ip link set eth2 up
ip addr add 10.1.1.9/30 dev eth2   # Link to nerrakeb-4

# Configure loopback (VTEP identifier)
echo "→ Configuring loopback..."
ip link add lo0 type dummy
ip addr add 1.1.1.1/32 dev lo0
ip link set lo0 up

# Enable IP forwarding
sysctl -w net.ipv4.ip_forward=1

echo ""
echo "→ Entering FRR configuration..."
sleep 2

# Configure FRR
vtysh << 'VTYSH_EOF'
configure terminal

! Set hostname
hostname nerrakeb-1

! Configure OSPF
router ospf
  network 10.1.1.0/30 area 0
  network 10.1.1.4/30 area 0
  network 10.1.1.8/30 area 0
  network 1.1.1.1/32 area 0
  exit

! Configure BGP
router bgp 1
  bgp router-id 1.1.1.1
  no bgp default ipv4-unicast
  
  ! Neighbors (all leaf routers)
  neighbor 1.1.1.2 remote-as 1
  neighbor 1.1.1.2 update-source lo0
  neighbor 1.1.1.3 remote-as 1
  neighbor 1.1.1.3 update-source lo0
  neighbor 1.1.1.4 remote-as 1
  neighbor 1.1.1.4 update-source lo0
  
  ! EVPN address family
  address-family l2vpn evpn
    neighbor 1.1.1.2 activate
    neighbor 1.1.1.2 route-reflector-client
    neighbor 1.1.1.3 activate
    neighbor 1.1.1.3 route-reflector-client
    neighbor 1.1.1.4 activate
    neighbor 1.1.1.4 route-reflector-client
    exit-address-family
  exit

! Save configuration
write memory
exit
VTYSH_EOF

echo ""
echo "=========================================="
echo "Configuration Complete"
echo "=========================================="
echo ""
echo "Loopback:"
ip addr show lo0 | grep inet
echo ""
echo "OSPF neighbors (wait 30s for adjacency):"
sleep 5
vtysh -c "show ip ospf neighbor"
echo ""
echo "BGP neighbors:"
vtysh -c "show bgp l2vpn evpn summary"
echo ""
