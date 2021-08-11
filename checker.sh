#!/bin/bash

source ./settings.sh
source ./check_pppoe.sh

unset WAN1_STATUS
unset WAN2_STATUS

# Check active interface
ACTIVE_IFACE=$(ip r g $CHECK_IP | awk '{ print $5 }')

# Make sure routes are set (in case routes get deleted after a PPPoE dies)
/bin/bash ./initroutes.sh &>/dev/null

# Check WAN1
if ping -c3 -w3 $WAN1_MONITOR_IP1 -I $WAN1_IFACE &>/dev/null && ping -c3 -w3 $WAN1_MONITOR_IP2 -I $WAN1_IFACE &>/dev/null
  then WAN1_STATUS=1
  else WAN1_STATUS=0 && echo "[$LOG_TIMESTAMP] $WAN1_SLUG detected offline" >> $LOG_DIR/checker.log
fi

# Check WAN2
if ping -c3 -w3 $WAN2_MONITOR_IP1 -I $WAN2_IFACE &>/dev/null && ping -c3 -w3 $WAN2_MONITOR_IP2 -I $WAN2_IFACE &>/dev/null
  then WAN2_STATUS=1
  else WAN2_STATUS=0 && echo "[$LOG_TIMESTAMP] $WAN2_SLUG detected offline" >> $LOG_DIR/checker.log
fi

# Load balancing when both are up
if [ "$WAN1_STATUS" -eq "1" ] && [ "$WAN2_STATUS" -eq "1" ];
  then
    if [ "$LB_ENABLE" -eq "1" ];
      then
        if ip r s default | grep $WAN1_IFACE &>/dev/null && ip r s default | grep $WAN2_IFACE &>/dev/null;
          then exit 0
          else ip r d default ; ip route add default scope global nexthop via $WAN1_GW dev $WAN1_IFACE weight $WAN1_WEIGHT nexthop via $WAN2_GW dev $WAN2_IFACE weight $WAN2_WEIGHT && echo "[$LOG_TIMESTAMP] $WAN1_SLUG and $WAN2_SLUG detected online, switching to load balancing" >> $LOG_DIR/checker.log
        fi
    elif [ "$LB_ENABLE" -eq "0" ];
      then
        if [ $WAN1_WEIGHT -gt $WAN2_WEIGHT ];
          then
            if ip r s default | grep $WAN2_IFACE &>/dev/null;
              then ip r d default; ip r a default via $WAN1_GW dev $WAN1_IFACE && echo "[$LOG_TIMESTAMP] $WAN1_SLUG and $WAN2_SLUG detected online, switched to $WAN1_SLUG as it has a greater weight" >> $LOG_DIR/checker.log
            fi
          else
            if ip r s default | grep $WAN1_IFACE &>/dev/null;
              then ip r d default; ip r a default via $WAN2_GW dev $WAN2_IFACE && echo "[$LOG_TIMESTAMP] $WAN1_SLUG and $WAN2_SLUG detected online, switched to $WAN2_SLUG as it has a greater weight" >> $LOG_DIR/checker.log
            fi
        fi
    fi
fi

# No routes when both are down
if [ "$WAN1_STATUS" -eq "0" ] && [ "$WAN2_STATUS" -eq "0" ];
  then WAN_STATUS=0 ; ip r d default ; conntrack --flush && echo "[$LOG_TIMESTAMP] $WAN1_SLUG and $WAN2_SLUG detected offline, removed default route" >> $LOG_DIR/checker.log && exit 0
fi

# Switch to WAN2 if WAN1 is down
if [ "$WAN1_STATUS" -eq "0" ];
  then
    if [ "$ACTIVE_IFACE" == "$WAN1_IFACE" ] || ip r s default | grep $WAN1_IFACE &>/dev/null
      then ip r d default ; ip r a default via $WAN2_GW dev $WAN2_IFACE && conntrack --flush && echo "[$LOG_TIMESTAMP] Switched default route from $WAN1_SLUG to $WAN2_SLUG" >> $LOG_DIR/checker.log
    fi
elif [ "$WAN1_STATUS" -eq "1" ];
  then
    if ! ip r s default | grep default &>/dev/null
      then ip r d default ; ip r a default via $WAN1_GW dev $WAN1_IFACE && conntrack --flush && echo "[$LOG_TIMESTAMP] Added default route to $WAN1_SLUG" >> $LOG_DIR/checker.log
    fi
fi

# Switch to WAN1 if WAN2 is down
if [ "$WAN2_STATUS" -eq "0" ];
  then
    if [ "$ACTIVE_IFACE" == "$WAN2_IFACE" ] || ip r s default | grep $WAN2_IFACE &>/dev/null
      then ip r d default ; ip r a default via $WAN1_GW dev $WAN1_IFACE && conntrack --flush && echo "[$LOG_TIMESTAMP] Switched default route from $WAN2_SLUG to $WAN1_SLUG" >> $LOG_DIR/checker.log
    fi
elif [ "$WAN2_STATUS" -eq "1" ];
  then
    if ! ip r s default | grep default &>/dev/null
      then ip r d default ; ip r a default via $WAN2_GW dev $WAN2_IFACE && conntrack --flush && echo "[$LOG_TIMESTAMP] Added default route to $WAN2_SLUG" >> $LOG_DIR/checker.log
    fi
fi
