#!/bin/bash

# BADASS Part 3 - BGP EVPN - ONE SCRIPT!

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

clear
echo "=========================================="
echo "BADASS Part 3 - BGP EVPN Setup"
echo "=========================================="
echo ""

# Main menu
echo "What do you want?"
echo ""
echo "1) Show GNS3 topology setup"
echo "2) Show all configurations (copy-paste)"
echo "3) Exit"
echo ""
printf "Choice [1-3]: "
read choice
echo ""

case "$choice" in
    1)
        clear
        cat << 'TOPOLOGY'
========================================
GNS3 TOPOLOGY SETUP
========================================

1. New Project: P3

2. Add Devices:
   • 4x routeur_nerrakeb (nerrakeb-1, nerrakeb-2, nerrakeb-3, nerrakeb-4)
   • 3x host_nerrakeb (host_nerrakeb-1, host_nerrakeb-2, host_nerrakeb-3)

3. Connect (Star topology):
   
            nerrakeb-1 (Route Reflector)
           /  |  \
          /   |   \
      nerrakeb-2 nerrakeb-3 nerrakeb-4 (Leaf VTEPs)
        |     |     |
     host1  host2  host3

   Connections:
   • nerrakeb-1 eth0 ↔ nerrakeb-2 eth0
   • nerrakeb-1 eth1 ↔ nerrakeb-3 eth0
   • nerrakeb-1 eth2 ↔ nerrakeb-4 eth0
   • nerrakeb-2 eth1 ↔ host_nerrakeb-1 eth0
   • nerrakeb-3 eth1 ↔ host_nerrakeb-2 eth0
   • nerrakeb-4 eth1 ↔ host_nerrakeb-3 eth0

4. Start all devices (Play button)

5. Run this script again → option 2

========================================
TOPOLOGY
        ;;
        
    2)
        clear
        echo "=========================================="
        echo "BGP EVPN CONFIGURATION"
        echo "=========================================="
        echo ""
        echo "Copy-paste these into GNS3 consoles:"
        echo ""
        
        echo -e "${YELLOW}=== NERRAKEB-1 (Route Reflector) ===${NC}"
        echo ""
        cat configs/nerrakeb-1_config.sh
        echo ""
        echo "---"
        echo ""
        
        echo -e "${YELLOW}=== NERRAKEB-2 (Leaf) ===${NC}"
        echo ""
        cat configs/nerrakeb-2_config.sh
        echo ""
        echo "---"
        echo ""
        
        echo -e "${YELLOW}=== NERRAKEB-3 (Leaf) ===${NC}"
        echo ""
        cat configs/nerrakeb-3_config.sh
        echo ""
        echo "---"
        echo ""
        
        echo -e "${YELLOW}=== NERRAKEB-4 (Leaf) ===${NC}"
        echo ""
        cat configs/nerrakeb-4_config.sh
        echo ""
        echo "---"
        echo ""
        
        echo -e "${YELLOW}=== HOST 1 ===${NC}"
        echo ""
        cat configs/host_nerrakeb-1_config.sh
        echo ""
        echo "---"
        echo ""
        
        echo -e "${YELLOW}=== HOST 2 ===${NC}"
        echo ""
        cat configs/host_nerrakeb-2_config.sh
        echo ""
        echo "---"
        echo ""
        
        echo -e "${YELLOW}=== HOST 3 ===${NC}"
        echo ""
        cat configs/host_nerrakeb-3_config.sh
        echo ""
        
        echo "=========================================="
        echo -e "${GREEN}✓ All configurations shown!${NC}"
        echo "=========================================="
        echo ""
        echo "After configuring, verify:"
        echo "• vtysh -c 'show bgp l2vpn evpn summary'"
        echo "• vtysh -c 'show evpn vni'"
        echo "• bridge fdb show"
        echo ""
        ;;
        
    3)
        echo "Bye! 👋"
        exit 0
        ;;
        
    *)
        echo "Invalid choice"
        exit 1
        ;;
esac

echo "Done! 🎉"
echo ""
