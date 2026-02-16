#!/bin/bash
#
# Host Configuration Script
# BADASS Project - Part 1
#
# This script configures the host container with:
# - IP address: 10.1.1.1/30
# - Default gateway: 10.1.1.2 (router)
#

echo "=========================================="
echo "Configuring Host"
echo "=========================================="

# Check if running in container
if [ ! -f /.dockerenv ]; then
    echo "Warning: Not running in Docker container"
fi

# Configure network interface eth0
echo "→ Configuring eth0 interface..."
ip addr add 10.1.1.1/30 dev eth0 2>/dev/null || true
ip link set eth0 up

# Add default route via router
echo "→ Adding default route..."
ip route add default via 10.1.1.2 2>/dev/null || true

# Display configuration
echo ""
echo "=========================================="
echo "Configuration Applied"
echo "=========================================="
echo ""
echo "Interface eth0:"
ip addr show eth0 | grep "inet "
echo ""
echo "Routing table:"
ip route show
echo ""

# Test connectivity
echo "=========================================="
echo "Testing Connectivity"
echo "=========================================="
echo "→ Ping router (10.1.1.2)..."
ping -c 3 -W 2 10.1.1.2

if [ $? -eq 0 ]; then
    echo ""
    echo "✓ Configuration successful!"
else
    echo ""
    echo "✗ Cannot reach router"
    echo "  Make sure router is configured and running"
fi

echo ""
