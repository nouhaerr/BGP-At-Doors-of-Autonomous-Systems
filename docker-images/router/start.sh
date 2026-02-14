#!/bin/bash

echo "=========================================="
echo "Starting Router Container"
echo "=========================================="

# Apply sysctl settings
sysctl -w net.ipv4.ip_forward=1 2>/dev/null
sysctl -w net.ipv6.conf.all.forwarding=1 2>/dev/null

sleep 1

# Start FRRouting
echo "Starting FRRouting daemons..."
/usr/lib/frr/frrinit.sh start

# Wait for daemons to start
sleep 3

# Check status
echo ""
echo "FRR Daemon Status:"
ps aux | grep -E 'zebra|bgpd|ospfd|isisd' | grep -v grep

echo ""
echo "=========================================="
echo "Router Ready!"
echo "Use 'vtysh' to configure routing"
echo "=========================================="
echo ""

# Give interactive bash shell instead of tail -f
exec /bin/bash
