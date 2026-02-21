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
   • 4x routeur_yourlogin (wil-1, wil-2, wil-3, wil-4)
   • 3x host_yourlogin (host_wil-1, host_wil-2, host_wil-3)

3. Connect (Star topology):
   
            wil-1 (Route Reflector)
           /  |  \
          /   |   \
      wil-2 wil-3 wil-4 (Leaf VTEPs)
        |     |     |
     host1  host2  host3

   Connections:
   • wil-1 eth0 ↔ wil-2 eth0
   • wil-1 eth1 ↔ wil-3 eth0
   • wil-1 eth2 ↔ wil-4 eth0
   • wil-2 eth1 ↔ host_wil-1 eth0
   • wil-3 eth1 ↔ host_wil-2 eth0
   • wil-4 eth1 ↔ host_wil-3 eth0

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
        
        echo -e "${YELLOW}=== WIL-1 (Route Reflector) ===${NC}"
        echo ""
        cat configs/wil-1_config.sh
        echo ""
        echo "---"
        echo ""
        
        echo -e "${YELLOW}=== WIL-2 (Leaf) ===${NC}"
        echo ""
        cat configs/wil-2_config.sh
        echo ""
        echo "---"
        echo ""
        
        echo -e "${YELLOW}=== WIL-3 (Leaf) ===${NC}"
        echo ""
        cat configs/wil-3_config.sh
        echo ""
        echo "---"
        echo ""
        
        echo -e "${YELLOW}=== WIL-4 (Leaf) ===${NC}"
        echo ""
        cat configs/wil-4_config.sh
        echo ""
        echo "---"
        echo ""
        
        echo -e "${YELLOW}=== HOST 1 ===${NC}"
        echo ""
        cat configs/host_wil-1_config.sh
        echo ""
        echo "---"
        echo ""
        
        echo -e "${YELLOW}=== HOST 2 ===${NC}"
        echo ""
        cat configs/host_wil-2_config.sh
        echo ""
        echo "---"
        echo ""
        
        echo -e "${YELLOW}=== HOST 3 ===${NC}"
        echo ""
        cat configs/host_wil-3_config.sh
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
