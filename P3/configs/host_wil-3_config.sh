#!/bin/bash
# Host 3 Configuration

echo "Configuring host_wil-3..."
ip addr add 20.1.1.3/24 dev eth0
ip link set eth0 up

echo "Host 3 configured: 20.1.1.3"
ip addr show eth0 | grep inet

echo ""
echo "Testing connectivity..."
ping -c 3 20.1.1.1
ping -c 3 20.1.1.2
