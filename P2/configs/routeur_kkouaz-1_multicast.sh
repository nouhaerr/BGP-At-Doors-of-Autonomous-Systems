#!/bin/bash
#
# Router 1 Configuration - Multicast VXLAN
# BADASS Project - Part 2
#
# This router is a VTEP with multicast for dynamic discovery
# Underlay IP: 10.1.1.1/24
# VXLAN: VNI 10, multicast group 239.1.1.1
#

echo "=========================================="
echo "Configuring routeur_kkouaz-1 - Multicast VXLAN"
echo "=========================================="

# Configure underlay network
echo "→ Configuring underlay network (eth0)..."
ip link set eth0 up
ip addr add 10.1.1.1/24 dev eth0

# Configure interface to host
echo "→ Configuring host interface (eth1)..."
ip link set eth1 up

# Create VXLAN interface with multicast
echo "→ Creating VXLAN interface with multicast (vxlan10)..."
ip link add vxlan10 type vxlan \
    id 10 \
    dstport 4789 \
    local 10.1.1.1 \
    group 239.1.1.1 \
    dev eth0

# Create bridge
echo "→ Creating bridge (br0)..."
ip link add br0 type bridge

# Add VXLAN and host interface to bridge
echo "→ Adding interfaces to bridge..."
ip link set vxlan10 master br0
ip link set eth1 master br0

# Bring everything up
echo "→ Bringing up interfaces..."
ip link set vxlan10 up
ip link set br0 up

# Display configuration
echo ""
echo "=========================================="
echo "Configuration Complete"
echo "=========================================="
echo ""
echo "Underlay network (eth0):"
ip addr show eth0 | grep "inet "
echo ""
echo "VXLAN interface (with multicast):"
ip -d link show vxlan10 | head -7
echo ""
echo "Bridge forwarding database:"
bridge fdb show dev vxlan10
echo ""

# Show multicast group
echo "Multicast group membership:"
ip maddr show dev eth0 | grep 239.1.1.1 || echo "  (Will join 239.1.1.1 when traffic flows)"

echo ""
