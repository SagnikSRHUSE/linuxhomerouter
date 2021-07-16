#!/bin/bash

source ./settings.sh

# Making sure appropriate routing tables exist
# Routing table for WAN1
if ! grep -Fxq "201 WAN1_RT" /etc/iproute2/rt_tables
then
     echo '201 WAN1_RT' >> /etc/iproute2/rt_tables
fi
# Routing table for WAN2
if ! grep -Fxq "202 WAN2_RT" /etc/iproute2/rt_tables
then
     echo '202 WAN2_RT' >> /etc/iproute2/rt_tables
fi

# Setting per WAN_IF routes
# Routes for WAN1
ip route add $WAN1_SUBNET dev $WAN1_IFACE src $WAN2_IP table 201
ip route add default via $WAN1_GW table 201
ip rule add from $WAN1_IP table 201

# Routes for WAN2
ip route add $WAN2_SUBNET dev $WAN2_IFACE src $WAN2_IP table 202
ip route add default via $WAN2_GW table 202
ip rule add from $WAN2_IP table 202

# Ensure direct routes
ip route add $WAN1_SUBNET dev $WAN1_IFACE src $WAN1_IP
ip route add $WAN2_SUBNET dev $WAN2_IFACE src $WAN2_IP

# Setting static routes for monitoring
# Routes for WAN1
ip route add $WAN1_MONITOR_IP1 via $WAN1_GW dev $WAN1_IFACE onlink
ip route add $WAN1_MONITOR_IP2 via $WAN1_GW dev $WAN1_IFACE onlink

# Routes for WAN2
ip route add $WAN2_MONITOR_IP1 via $WAN2_GW dev $WAN2_IFACE onlink
ip route add $WAN2_MONITOR_IP2 via $WAN2_GW dev $WAN2_IFACE onlink
