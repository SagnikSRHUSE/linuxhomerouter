#!/bin/bash

source ./settings.sh

WKG_DIR="/opt/fwscripts"
cd $WKG_DIR

# Setup routes and iptables

/bin/bash $WKG_DIR/initroutes.sh
/bin/bash $WKG_DIR/initfw.sh

while true; do sleep $CHECK_INTERVAL; /bin/bash $WKG_DIR/checker.sh; done
