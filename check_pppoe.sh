#!/bin/bash

source ./settings.sh

for iface in $PPPOE_INTERFACES; do
  if ip a | grep $iface &>/dev/null
    then exit 0
  fi
done

if [ -f $PPPOE_CHECK_FILE ]
  then echo "[$LOG_TIMESTAMP] PPPoE already being reestablished" >> $LOG_DIR/checker.log && sleep 5 && exit 0
fi

touch /tmp/check_pppoe

for iface in $PPPOE_INTERFACES; do
  if ! ip a | grep $iface &>/dev/null
    then pon $iface &>/dev/null && echo "[$LOG_TIMESTAMP] $iface PPPoE detected inactive, attempting to reinitiate" >> $LOG_DIR/checker.log
  fi
done

