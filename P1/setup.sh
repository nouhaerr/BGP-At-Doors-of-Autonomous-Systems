
#!/bin/bash

# BADASS Project - Part 1 Setup
# This script helps configure GNS3 with Docker images

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

# Instructions for GNS3
echo "=========================================="
echo "GNS3 Configuration Instructions"
echo "=========================================="
echo ""
echo "1. Add Host Image to GNS3:"
echo "   • Edit → Preferences → Docker → Docker containers → New"
echo "   • Existing image: host-alpine:1.0"
echo "   • Name: host_yourlogin"
echo "   • Adapters: 1"
echo "   • Start command: /bin/bash"
echo "   • Console: telnet"
echo ""
echo "2. Add Router Image to GNS3:"
echo "   • Existing image: router-frr:1.0"
echo "   • Name: routeur_yourlogin"
echo "   • Adapters: 2"
echo "   • Start command: /start.sh"
echo "   • Console: telnet"
echo ""
echo "3. Import P1.gns3project in GNS3"
echo "4. Connect devices: Press 'A' and link eth0 ↔ eth0"
echo "5. Configure as per CONFIGURATION_COMMANDS.md"
echo ""

# Quick test option
echo "=========================================="
echo "Quick Test (Optional)"
echo "=========================================="
echo ""
read -p "Test images before GNS3? (y/n): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "→ Cleaning test environment..."
    
    # Nuclear cleanup
    docker stop badass-router badass-host 2>/dev/null || true
    docker rm badass-router badass-host 2>/dev/null || true
    docker network rm badass-test 2>/dev/null || true
    
    # Remove any conflicting bridges
    for bridge in $(ip link show 2>/dev/null | grep "br-" | awk '{print $2}' | sed 's/:$//'); do
        if ip addr show $bridge 2>/dev/null | grep -q "10\.1\.1\|172\.20\.0"; then
            sudo ip link delete $bridge 2>/dev/null || true
        fi
    done
    
    sleep 2
    
    echo "→ Creating isolated test network..."
    # Use different subnet to avoid conflicts
    if ! docker network create --subnet=172.20.0.0/29 badass-test 2>/dev/null; then
        echo -e "${YELLOW}✗ Network creation failed - trying cleanup...${NC}"
        docker network prune -f
        sleep 1
        docker network create --subnet=172.20.0.0/29 badass-test || {
            echo -e "${YELLOW}✗ Still failing - skip test and use GNS3 instead${NC}"
            exit 0
        }
    fi
    
    echo "→ Starting router (172.20.0.2)..."
    docker run -d --rm --privileged \
        --network badass-test \
        --ip 172.20.0.3 \
        --name badass-router \
        router-frr:1.0 2>&1 | head -1
    
    sleep 3
    
    echo "→ Starting host (172.20.0.1)..."
    docker run -d --rm \
        --network badass-test \
        --ip 172.20.0.2 \
        --name badass-host \
        host-alpine:1.0 \
        tail -f /dev/null 
    
    sleep 3
    
    # Verify containers are running
    if ! docker ps | grep -q badass-router; then
        echo -e "${YELLOW}✗ Router not running${NC}"
        docker logs badass-router 2>&1 | tail -10
        docker network rm badass-test 2>/dev/null
        exit 0
    fi
    
    if ! docker ps | grep -q badass-host; then
        echo -e "${YELLOW}✗ Host not running${NC}"
        docker stop badass-router 2>/dev/null
        docker network rm badass-test 2>/dev/null
        exit 0
    fi
    
    echo "→ Testing connectivity..."
    echo ""
    
    if docker exec badass-host ping -c 3 172.20.0.3 2>/dev/null; then
        echo ""
        echo -e "${GREEN}✓ SUCCESS! Images work perfectly.${NC}"
    else
        echo -e "${YELLOW}✗ Ping failed but containers are running${NC}"
    fi
    
    echo ""
    echo "→ Cleaning up..."
    docker stop badass-router badass-host 2>/dev/null
    docker network rm badass-test 2>/dev/null
    
    echo -e "${GREEN}✓ Done${NC}"
fi

echo ""
echo "=========================================="
echo "Ready for GNS3!"
echo "=========================================="
echo ""
echo "Import P1.gns3project and configure devices"
echo "See: CONFIGURATION_COMMANDS.md"
echo ""
