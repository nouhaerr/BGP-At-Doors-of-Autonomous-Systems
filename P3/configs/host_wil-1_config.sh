#!/bin/bash
# Host 1 Configuration

echo "Configuring host_wil-1..."
ip addr add 20.1.1.1/24 dev eth0
ip link set eth0 up

echo "Host 1 configured: 20.1.1.1"
ip addr show eth0 | grep inet

echo ""
echo "Testing connectivity..."
ping -c 3 20.1.1.2
ping -c 3 20.1.1.3
