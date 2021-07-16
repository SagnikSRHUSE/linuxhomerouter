#!/bin/bash

source ./settings.sh

# Load modules
modprobe ip_tables
modprobe ip_conntrack
modprobe ip_conntrack_irc
modprobe ip_conntrack_ftp

# Enable IPv4 forwarding
sysctl -w net.ipv4.ip_forward=1
# Increase conntract limit
sysctl -w net.nf_conntrack_max=1048576

# Start from a blank slate. Flush all iptables rules
iptables -F
iptables -X
iptables -Z

# Default policy to drop all incoming and forwarded packets.
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Accept incoming packets from localhost and the LAN interface.
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -i $LAN_IFACE -j ACCEPT

# Allow ICMP from WAN
iptables -A INPUT -i $WAN1_IFACE -p icmp -j ACCEPT
iptables -A INPUT -i $WAN2_IFACE -p icmp -j ACCEPT

# Accept incoming packets from the WAN if the router initiated the connection.
iptables -A INPUT -i $WAN1_IFACE -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -i $WAN2_IFACE -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Accept forwarded packets from LAN to the WAN.
iptables -A FORWARD -i $LAN_IFACE -o $WAN1_IFACE -j ACCEPT
iptables -A FORWARD -i $LAN_IFACE -o $WAN2_IFACE -j ACCEPT

# Accept forwarded packets from WAN to the LAN if the LAN initiated the connection.
iptables -A FORWARD -i $WAN1_IFACE -o $LAN_IFACE -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -i $WAN2_IFACE -o $LAN_IFACE -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# NAT traffic going out the WAN.
iptables -t nat -A POSTROUTING -o $WAN1_IFACE -j MASQUERADE
iptables -t nat -A POSTROUTING -o $WAN2_IFACE -j MASQUERADE

exit 0
