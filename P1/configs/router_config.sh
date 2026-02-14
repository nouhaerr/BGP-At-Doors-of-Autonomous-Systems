#!/bin/bash
#
# Router Configuration Script  
# BADASS Project - Part 1
#
# This script configures the router with:
# - IP address: 10.1.1.2/30 on eth0
# - IP forwarding enabled
# - FRRouting basic setup
#

echo "=========================================="
echo "Configuring Router"
echo "=========================================="

# Enable IP forwarding
echo "→ Enabling IP forwarding..."
sysctl -w net.ipv4.ip_forward=1 2>/dev/null

# Configure network interface
echo "→ Configuring eth0 interface..."
ip addr add 10.1.1.2/30 dev eth0 2>/dev/null || true
ip link set eth0 up

# Display current configuration
echo ""
echo "=========================================="
echo "Basic Configuration Applied"
echo "=========================================="
echo ""
echo "Interface eth0:"
ip addr show eth0 | grep "inet "
echo ""
echo "IP Forwarding:"
sysctl net.ipv4.ip_forward
echo ""

# Configure FRRouting
echo "=========================================="
echo "Configuring FRRouting"
echo "=========================================="

# Wait for FRR to be ready
sleep 2

# Configure via vtysh
vtysh << VTYSH_EOF
configure terminal
!
! Set hostname
hostname routeur_badass
!
! Configure interface eth0
interface eth0
  description Link to host
  ip address 10.1.1.2/30
  no shutdown
  exit
!
! Save configuration
write memory
!
exit
VTYSH_EOF

echo ""
echo "→ FRR configuration applied"
echo ""

# Show configuration
echo "=========================================="
echo "Current FRR Configuration"
echo "=========================================="
vtysh -c "show running-config"

echo ""
echo "=========================================="
echo "Testing Connectivity"
echo "=========================================="
echo "→ Ping host (10.1.1.1)..."
ping -c 3 -W 2 10.1.1.1

if [ $? -eq 0 ]; then
    echo ""
    echo "✓ Configuration successful!"
else
    echo ""
    echo "✗ Cannot reach host"
    echo "  Make sure host is configured and running"
fi

echo ""
