#!/bin/bash
IF=$1


if [ -e /etc/sysconfig/network-scripts/ifcfg-${IF} ]
then
   RET=$(cat /etc/sysconfig/network-scripts/ifcfg-${IF} | grep "HWADDR")
   if [[ "${RET}" == "" ]]
   then
      # Get HWADDR
      HWADDR=`ifconfig ${IF} | grep "HWaddr" | awk '{print $5}'`
      echo "HWADDR=$HWADDR" >> /etc/sysconfig/network-scripts/ifcfg-${IF}
      echo "HWADDR=$HWADDR set for ${IF}"
   else
      echo "HW address already set for ${IF}"
   fi
fi
