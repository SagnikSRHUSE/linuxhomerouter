#!/bin/bash

source ./settings.sh

for iface in $PPPOE_INTERFACES; do
  if ! ip a | grep $iface &>/dev/null
    then
      if pgrep -f "/usr/sbin/pppd call $iface" &>/dev/null;
        then echo "[$LOG_TIMESTAMP] $iface PPPoE is being reestablished" >> $LOG_DIR/checker.log
      elif ! pgrep -f "/usr/sbin/pppd call $iface" &>/dev/null;
        then pon $iface &>/dev/null && echo "[$LOG_TIMESTAMP] $iface PPPoE detected inactive, attempting to reinitiate" >> $LOG_DIR/checker.log
      fi
  fi
done
