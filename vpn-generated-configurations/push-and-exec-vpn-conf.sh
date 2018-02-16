#!/bin/bash

if [[ $@ -ne 2 ]] ;
then
  echo "USAGE $0 SSH_CONF_FILE VPN_CONF_FILE"
  exit 1
fi

SSH_CONF_FILE="$1"
VPN_CONF_FILE="$2"

HOST="vyos"

scp -F $SSH_CONF_FILE $VPN_CONF_FILE ${HOST}:/tmp/${VPN_CONF_FILE}
ssh -F $SSH_CONF_FILE ${HOST} bash /tmp/${VPN_CONF_FILE}
#ssh -F $SSH_CONF_FILE ${HOST} echo "Yes" | reboot
