#!/bin/bash

# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# echo an error message before exiting
trap 'echo "\"${last_command}\" command filed with exit code $?."' EXIT

LAN_IFACE="eth0"

# WAN1 == SSWL
WAN1_IFACE="eth1"
WAN1_IP=$(ip addr show dev $WAN1_IFACE | grep "inet " | awk '{ print $2 }' | awk -F/ '{ print $1 }')
WAN1_GW="10.5.235.1"
WAN1_SUBNET=$(echo $WAN1_IP | cut -d'.' -f1-3).0/$(ip addr show dev $WAN1_IFACE | grep "inet " | awk '{ print $2 }' | awk -F/ '{ print $2 }')
WAN1_WEIGHT=1
WAN1_SLUG="SSWL"

# WAN2 == Airtel
#WAN2_IFACE="eth2"
WAN2_IFACE="airtel-pppoe"
WAN2_IP=$(ip addr show dev $WAN2_IFACE | grep "inet " | awk '{ print $2 }' | awk -F/ '{ print $1 }')
WAN2_GW=$(ip addr show $WAN2_IFACE | grep peer | grep global | awk '{ print $4}' | sed 's/\/32//')
WAN2_SUBNET=$WAN2_GW
#WAN2_GW="192.168.42.1"
#WAN2_SUBNET=$(echo $WAN2_IP | cut -d'.' -f1-3).0/$(ip addr show dev $WAN2_IFACE | grep "inet " | awk '{ print $2 }' | awk -F/ '{ print $2 }')
WAN2_WEIGHT=10
WAN2_SLUG="Airtel PPPoE"

PPPOE_INTERFACES=$WAN2_IFACE

# Monitoring vars
CHECK_INTERVAL=0

WAN1_MONITOR_IP1="1.1.1.2"
WAN1_MONITOR_IP2="9.9.9.9"

WAN2_MONITOR_IP1="1.1.1.3"
WAN2_MONITOR_IP2="149.112.112.112"

# Vars for determining active interface
CHECK_IP="208.67.222.222"

# Misc vars
WKG_DIR="/opt/fwscripts"
LB_ENABLE=0
PPPOE_CHECK_FILE="/tmp/check_pppoe"

# Log vars
LOG_DIR="/var/log/fw"
LOG_TIMESTAMP=$(TZ=Asia/Kolkata date '+%Y-%m-%d %H:%M:%S')
