#!/bin/bash

source ./settings.sh

for iface in $PPPOE_INTERFACES; do
  if ! ip a | grep $iface &>/dev/null
    then pon $iface &>/dev/null && echo "[$LOG_TIMESTAMP] $iface PPPoE detected inactive, attempting to reinitiate" >> $LOG_DIR/checker.log
  fi
done
