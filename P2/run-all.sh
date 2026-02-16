#!/bin/bash

# BADASS Part 2 - ONE SCRIPT TO RUN EVERYTHING
# Just run this and follow prompts!

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

clear
echo "=========================================="
echo "BADASS Part 2 - Complete Setup"
echo "=========================================="
echo ""

# Check images
echo -e "${BLUE}Checking Docker images...${NC}"
if ! docker images | grep -q "host-alpine.*1.0"; then
    echo -e "${YELLOW}✗ Images not found. Run: cd .. && bash build_all.sh${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Images ready${NC}"
echo ""

# Main menu
echo "=========================================="
echo "What do you want to do?"
echo "=========================================="
echo ""
echo "1) Show me GNS3 setup instructions"
echo "2) Give me Static VXLAN configs (copy-paste)"
echo "3) Give me Multicast VXLAN configs (copy-paste)"
echo "4) Exit"
echo ""
printf "Choice [1-4]: "
read choice
echo ""

case "$choice" in
    1)
        clear
        echo "=========================================="
        echo "GNS3 TOPOLOGY SETUP"
        echo "=========================================="
        echo ""
        echo "1. Open GNS3 → New Project → Name: P2"
        echo ""
        echo "2. Drag to workspace:"
        echo "   • 1x Ethernet switch"
        echo "   • 2x routeur_yourlogin"  
        echo "   • 2x host_yourlogin"
        echo ""
        echo "3. Connect (press 'A' to add links):"
        echo "   • Switch eth0 ↔ Router1 eth0"
        echo "   • Switch eth1 ↔ Router2 eth0"
        echo "   • Router1 eth1 ↔ Host1 eth0"
        echo "   • Router2 eth1 ↔ Host2 eth0"
        echo ""
        echo "4. Click green Play ▶ button"
        echo ""
        echo "5. Run this script again and choose option 2 or 3"
        echo ""
        ;;
        
    2)
        clear
        echo "=========================================="
        echo "STATIC VXLAN - COPY THESE TO GNS3"
        echo "=========================================="
        echo ""
        echo -e "${YELLOW}=== ROUTER 1 ===${NC}"
        echo "Right-click Router1 → Console, then paste:"
        echo ""
        cat << 'R1'
ip link set eth0 up
ip addr add 10.1.1.1/24 dev eth0
ip link set eth1 up
ip link add vxlan10 type vxlan id 10 dstport 4789 local 10.1.1.1 remote 10.1.1.2
ip link add br0 type bridge
ip link set vxlan10 master br0
ip link set eth1 master br0
ip link set vxlan10 up
ip link set br0 up
echo "✓ Router 1 configured"
R1
        echo ""
        echo -e "${YELLOW}=== ROUTER 2 ===${NC}"
        echo "Right-click Router2 → Console, then paste:"
        echo ""
        cat << 'R2'
ip link set eth0 up
ip addr add 10.1.1.2/24 dev eth0
ip link set eth1 up
ip link add vxlan10 type vxlan id 10 dstport 4789 local 10.1.1.2 remote 10.1.1.1
ip link add br0 type bridge
ip link set vxlan10 master br0
ip link set eth1 master br0
ip link set vxlan10 up
ip link set br0 up
echo "✓ Router 2 configured"
R2
        echo ""
        echo -e "${YELLOW}=== HOST 1 ===${NC}"
        echo "Right-click Host1 → Console, then paste:"
        echo ""
        cat << 'H1'
ip addr add 20.1.1.1/24 dev eth0
ip link set eth0 up
echo "✓ Host 1 configured"
ping -c 3 20.1.1.2
H1
        echo ""
        echo -e "${YELLOW}=== HOST 2 ===${NC}"
        echo "Right-click Host2 → Console, then paste:"
        echo ""
        cat << 'H2'
ip addr add 20.1.1.2/24 dev eth0
ip link set eth0 up
echo "✓ Host 2 configured"
ping -c 3 20.1.1.1
H2
        echo ""
        echo -e "${GREEN}✓ If ping works, VXLAN is working!${NC}"
        echo ""
        ;;
        
    3)
        clear
        echo "=========================================="
        echo "MULTICAST VXLAN - COPY THESE TO GNS3"
        echo "=========================================="
        echo ""
        echo -e "${YELLOW}=== ROUTER 1 ===${NC}"
        echo "Right-click Router1 → Console, then paste:"
        echo ""
        cat << 'MR1'
ip link set eth0 up
ip addr add 10.1.1.1/24 dev eth0
ip link set eth1 up
ip link add vxlan10 type vxlan id 10 dstport 4789 local 10.1.1.1 group 239.1.1.1 dev eth0
ip link add br0 type bridge
ip link set vxlan10 master br0
ip link set eth1 master br0
ip link set vxlan10 up
ip link set br0 up
echo "✓ Router 1 configured (multicast)"
MR1
        echo ""
        echo -e "${YELLOW}=== ROUTER 2 ===${NC}"
        echo "Right-click Router2 → Console, then paste:"
        echo ""
        cat << 'MR2'
ip link set eth0 up
ip addr add 10.1.1.2/24 dev eth0
ip link set eth1 up
ip link add vxlan10 type vxlan id 10 dstport 4789 local 10.1.1.2 group 239.1.1.1 dev eth0
ip link add br0 type bridge
ip link set vxlan10 master br0
ip link set eth1 master br0
ip link set vxlan10 up
ip link set br0 up
echo "✓ Router 2 configured (multicast)"
MR2
        echo ""
        echo -e "${YELLOW}=== HOST 1 ===${NC}"
        echo "Right-click Host1 → Console, then paste:"
        echo ""
        cat << 'MH1'
ip addr add 20.1.1.1/24 dev eth0
ip link set eth0 up
echo "✓ Host 1 configured"
ping -c 3 20.1.1.2
MH1
        echo ""
        echo -e "${YELLOW}=== HOST 2 ===${NC}"
        echo "Right-click Host2 → Console, then paste:"
        echo ""
        cat << 'MH2'
ip addr add 20.1.1.2/24 dev eth0
ip link set eth0 up
echo "✓ Host 2 configured"
ping -c 3 20.1.1.1
MH2
        echo ""
        echo -e "${GREEN}✓ If ping works, Multicast VXLAN is working!${NC}"
        echo ""
        ;;
        
    4)
        echo "Bye! 👋"
        exit 0
        ;;
        
    *)
        echo "Invalid choice"
        exit 1
        ;;
esac

echo "=========================================="
echo "Done! 🎉"
echo "=========================================="
echo ""
