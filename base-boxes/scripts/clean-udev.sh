for nic in /etc/sysconfig/network-scripts/ifcfg-eth*; do sed -i /HWADDR/d $nic; done
 rm /etc/udev/rules.d/70-persistent-net.rules
