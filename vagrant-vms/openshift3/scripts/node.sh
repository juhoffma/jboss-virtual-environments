#!/bin/sh
#
# Params
#   $1: hostname
#
_HOSTNAME=$1


# USE ndoe 1 AS DNS SERVER
if [[ "$1" == "ose3-node1" ]]
then 
   # Enable and set dnsmasq
   cat > /etc/dnsmasq.conf <<EOF
strict-order
domain-needed
local=/example.com/
bind-dynamic
address=/.cloudapps.example.com/192.168.133.2
log-queries
#conf-file=/etc/dnsmasq.more.conf
conf-dir=/etc/dnsmasq.d
EOF
   systemctl enable dnsmasq
   systemctl start dnsmasq
   systemctl status dnsmasq
fi
