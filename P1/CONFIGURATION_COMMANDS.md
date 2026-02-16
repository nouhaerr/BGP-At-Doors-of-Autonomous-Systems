# Part 1 Configuration Commands

## Quick Reference

### Host Configuration
```bash
ip addr add 10.1.1.1/30 dev eth0
ip link set eth0 up
ip route add default via 10.1.1.2
ping -c 4 10.1.1.2
```

### Router Configuration
```bash
# Configure interface in bash
ip addr add 10.1.1.2/30 dev eth0
ip link set eth0 up

# Configure via FRR
vtysh
configure terminal
hostname routeur_sienna
interface eth0
  description Link to host
  ip address 10.1.1.2/30
  no shutdown
  exit
write memory
exit

# Test (back in bash)
ping -c 4 10.1.1.1
```

## Verification

### On Host
```bash
ip addr show eth0      # Should show 10.1.1.1/30
ip route show          # Should show default via 10.1.1.2
ping 10.1.1.2         # Should work
```

### On Router
```bash
ip addr show eth0              # Should show 10.1.1.2/30
sysctl net.ipv4.ip_forward    # Should be 1
vtysh -c "show ip route"      # Should show connected route
vtysh -c "show running-config" # Should show your config
ping 10.1.1.1                 # Should work
```
