#!/bin/bash
#
# Host 1 Configuration - VXLAN Part 2
# BADASS Project
#
# This host is in the VXLAN network (VNI 10)
# IP: 20.1.1.1/24
#

echo "=========================================="
echo "Configuring host_login-1"
echo "=========================================="

# Configure interface
echo "→ Configuring eth0..."
ip addr add 20.1.1.1/24 dev eth0
ip link set eth0 up

# Display configuration
echo ""
echo "Configuration applied:"
ip addr show eth0 | grep "inet "
echo ""
echo "Routing table:"
ip route show
echo ""

# Test connectivity
echo "=========================================="
echo "Testing Connectivity"
echo "=========================================="
echo "→ Ping host_login-2 (20.1.1.2)..."
ping -c 3 20.1.1.2

if [ $? -eq 0 ]; then
    echo ""
    echo "✓ VXLAN is working! Can reach host-2"
else
    echo ""
    echo "✗ Cannot reach host-2 yet"
    echo "  Configure routers first"
fi

echo ""
