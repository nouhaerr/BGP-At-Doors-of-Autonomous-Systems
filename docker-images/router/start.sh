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

# [FIX 1] Create the missing directory for PID files (CRITICAL)
mkdir -p /run/frr
chown frr:frr /run/frr

# [FIX 2] Use watchfrr directly (frrinit.sh does not work in Docker)
/usr/lib/frr/watchfrr -d -F traditional zebra bgpd ospfd isisd

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

# [FIX 3] Smart Exit: Works in GNS3 (Bash) AND Build Script (Keep Alive)
if [ -t 0 ]; then
    # We have a terminal (GNS3 or docker run -it) -> Run Bash
    exec /bin/bash
else
    # No terminal (Build Script/Detached) -> Keep running forever
    exec tail -f /dev/null
fi