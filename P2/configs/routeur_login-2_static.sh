#!/bin/bash
#
# Router 2 Configuration - Static VXLAN
# BADASS Project - Part 2
#
# This router is a VTEP (VXLAN Tunnel Endpoint)
# Underlay IP: 10.1.1.2/24 (to other router)
# VXLAN: VNI 10, static remote VTEP
#

echo "=========================================="
echo "Configuring routeur_login-2 - Static VXLAN"
echo "=========================================="

# Configure underlay network (connection to other router via switch)
echo "→ Configuring underlay network (eth0)..."
ip link set eth0 up
ip addr add 10.1.1.2/24 dev eth0

# Configure interface to host
echo "→ Configuring host interface (eth1)..."
ip link set eth1 up

# Create VXLAN interface
echo "→ Creating VXLAN interface (vxlan10)..."
ip link add vxlan10 type vxlan \
    id 10 \
    dstport 4789 \
    local 10.1.1.2 \
    remote 10.1.1.1

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
echo "Bridge (br0):"
ip link show br0
echo ""
echo "VXLAN interface:"
ip -d link show vxlan10 | head -5
echo ""
echo "Bridge forwarding database:"
bridge fdb show dev vxlan10
echo ""

# Test underlay connectivity
echo "=========================================="
echo "Testing Underlay Connectivity"
echo "=========================================="
echo "→ Ping router 1 (10.1.1.1)..."
ping -c 3 10.1.1.1

echo ""
