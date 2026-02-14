#!/bin/bash

# BADASS Project - Part 1 Setup
# This script helps configure GNS3 with Docker images

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=========================================="
echo "BADASS Project - Part 1 Setup"
echo "=========================================="
echo ""

# Check if Docker images exist
echo -e "${BLUE}Checking Docker images...${NC}"
if ! docker image inspect host-alpine:1.0 > /dev/null 2>&1; then
    echo -e "${YELLOW}✗ host-alpine:1.0 not found${NC}"
    echo "Please run: cd .. && bash build_all.sh"
    exit 1
fi

if ! docker image inspect router-frr:1.0 > /dev/null 2>&1; then
    echo -e "${YELLOW}✗ router-frr:1.0 not found${NC}"
    echo "Please run: cd .. && bash build_all.sh"
    exit 1
fi

echo -e "${GREEN}✓ Both Docker images found${NC}"
echo ""

# Display configuration files
echo "=========================================="
echo "Configuration Files Available"
echo "=========================================="
echo ""
echo "For Host Container:"
echo "  Location: configs/host_config.sh"
echo "  Usage: Copy to container and run"
echo ""
echo "For Router Container:"
echo "  Location: configs/router_config.sh"
echo "  Usage: Copy to container and run"
echo ""

# Instructions for GNS3
echo "=========================================="
echo "GNS3 Configuration Instructions"
echo "=========================================="
echo ""
echo "1. Add Host Image to GNS3:"
echo "   • Edit → Preferences → Docker → Docker containers → New"
echo "   • Existing image: host-alpine:1.0"
echo "   • Name: host_yourlogin (replace with your login)"
echo "   • Adapters: 1"
echo "   • Start command: /bin/bash"
echo "   • Console: telnet"
echo ""
echo "2. Add Router Image to GNS3:"
echo "   • Edit → Preferences → Docker → Docker containers → New"
echo "   • Existing image: router-frr:1.0"
echo "   • Name: routeur_yourlogin (replace with your login)"
echo "   • Adapters: 2"
echo "   • Start command: /start.sh"
echo "   • Console: telnet"
echo ""
echo "3. Create Topology:"
echo "   • Drag host_yourlogin to workspace"
echo "   • Drag routeur_yourlogin to workspace"
echo "   • Connect: host eth0 ↔ router eth0"
echo ""
echo "4. Start Devices:"
echo "   • Click green Play button"
echo ""
echo "5. Configure Devices:"
echo ""
echo "   On HOST console:"
echo "   ----------------"
cat << 'HOSTCMD'
   # Copy config script
   cat > /config.sh << 'SCRIPT'
   #!/bin/bash
   ip addr add 10.1.1.1/30 dev eth0
   ip link set eth0 up
   ip route add default via 10.1.1.2
   echo "Host configured: 10.1.1.1/30"
   SCRIPT
   chmod +x /config.sh
   /config.sh
   
   # Test
   ping -c 4 10.1.1.2
HOSTCMD
echo ""
echo "   On ROUTER console:"
echo "   ------------------"
cat << 'ROUTERCMD'
   # Router config via bash
   ip addr add 10.1.1.2/30 dev eth0
   ip link set eth0 up
   
   # Configure via vtysh
   vtysh
   configure terminal
   hostname routeur_yourlogin
   interface eth0
     description Link to host
     ip address 10.1.1.2/30
     no shutdown
     exit
   write memory
   exit
   
   # Test
   ping -c 4 10.1.1.1
ROUTERCMD
echo ""

# Quick test option
echo "=========================================="
echo "Quick Test (Optional)"
echo "=========================================="
echo ""
echo "To quickly test the images before GNS3:"
read -p "Run quick test? (y/n): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "Starting test containers..."
    
    # Create network
    docker network create --subnet=10.1.1.0/30 badass-test 2>/dev/null || true
    
    # Start router
    echo "→ Starting router..."
    ROUTER_ID=$(docker run -d --rm --privileged \
        --network badass-test \
        --ip 10.1.1.2 \
        --name badass-router \
        router-frr:1.0)
    
    # Start host
    echo "→ Starting host..."
    HOST_ID=$(docker run -d --rm \
        --network badass-test \
        --ip 10.1.1.1 \
        --name badass-host \
        host-alpine:1.0 \
        tail -f /dev/null)
    
    # Wait for startup
    sleep 5
    
    # Test connectivity
    echo "→ Testing connectivity..."
    docker exec badass-host ping -c 3 10.1.1.2
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Test successful!${NC}"
    else
        echo -e "${YELLOW}✗ Test failed${NC}"
    fi
    
    # Cleanup
    echo "→ Cleaning up..."
    docker stop badass-router badass-host 2>/dev/null || true
    docker network rm badass-test 2>/dev/null || true
    
    echo ""
fi

echo "=========================================="
echo "Ready for GNS3!"
echo "=========================================="
echo ""
echo "Next: Open GNS3 and follow the instructions above"
echo ""

